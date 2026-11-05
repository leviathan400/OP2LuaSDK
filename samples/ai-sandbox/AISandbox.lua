-- AISandbox.lua  -  AI Sandbox (Nostalgia)
--
-- The testbed for an autonomous, goal-driven base AI (player 2) that builds FOR REAL - no cheat-
-- spawning. OP2 has no native AI, so it's scripted against the OP2Lua API, throttled on the scheduler.
-- Nostalgia is the clean multiplayer-map template; experiment here. See docs/AI-DESIGN.md.
--
-- PHASE 1 (this version): PERCEPTION + DISCOVERY. On spawn the AI reads its own situation from the live
-- game - its assets, what's stored in its Structure Factory, and (by discovery, not a hardcoded handle)
-- where its nearest beacons are - then brings up the mining economy on the beacon it found.
-- NEXT (phase 2+): a goal/task brain (build + tube structures from SF kits, army, maintenance).
--
-- Win: destroy the enemy Command Center.   Lose: lose yours.

local AI = 2   -- the computer player's index in players[]

local function first(list) return list[1] end
local function dist2(a, b) local dx, dy = a.x - b.x, a.y - b.y; return (dx * dx) + (dy * dy) end

-- PERCEPTION: build a picture of the AI's situation from the live game (no hardcoded map knowledge).
-- Returns the nearest Common-ore beacon (a Unit) for the miner to claim.
local function ai_perceive()
  local p  = players[AI]
  local cc = first(p:units("CommandCenter"))
  local sf = first(p:units("StructureFactory"))
  local ref = cc or sf                       -- measure distances from the base
  print("=== AI perception ===")
  print(string.format("  assets: CC=%s SF=%s  convec=%d truck=%d miner=%d surveyor=%d",
    tostring(cc ~= nil), tostring(sf ~= nil), p:unit_count("ConVec"), p:unit_count("CargoTruck"),
    p:unit_count("RoboMiner"), p:unit_count("RoboSurveyor")))
  print(string.format("  resources: ore=%d rare=%d food=%d  pop=%d (kids=%d workers=%d scientists=%d)",
    p.ore, p.rare_ore, p.food, p.population, p.kids, p.workers, p.scientists))

  -- "what do I have in my SF?"
  if sf then
    local kits = {}
    for bay = 1, 6 do local k = sf:factory_cargo(bay); if k ~= "None" then kits[#kits + 1] = k end end
    print("  SF storage: " .. (#kits > 0 and table.concat(kits, ", ") or "(empty)"))
  end

  -- "what's my closest mine? where is the next one?" - discover beacons, rank by distance.
  local beacons = game.beacons("Common")
  if #beacons == 0 then beacons = game.beacons() end          -- fall back to any ore type
  if ref then table.sort(beacons, function(a, b) return dist2(a, ref) < dist2(b, ref) end) end
  print(string.format("  %d beacon(s) on the map; nearest:", #beacons))
  for n = 1, math.min(3, #beacons) do
    local b = beacons[n]
    local d = ref and math.floor(math.sqrt(dist2(b, ref))) or -1
    print(string.format("    #%d  %s ore at (%d,%d)  dist=%d", n, b.ore, b.x, b.y, d))
  end

  -- "can I see the map?" terrain awareness (cliffs/lava/passability) - the basis for zoning + chokes.
  local sz = game.map_size()
  print(string.format("  map: %dx%d tiles", sz.w, sz.h))
  if ref then
    local strip = {}
    for dx = 1, 10 do
      local c = game.cell(ref.x + dx, ref.y)
      strip[#strip + 1] = c.cliff and "C" or c.lava and "L" or (not c.passable) and "X"
                          or c.blocked and "#" or "."
    end
    print("  terrain E of base: " .. table.concat(strip) .. "   (. open  # built  X blocked  C cliff  L lava)")
  end

  return beacons[1]
end

-- Bring the mining economy online on the discovered beacon: survey -> deploy mine -> route trucks.
local function ai_bring_up_mining()
  local target   = ai_perceive()
  local surveyor = first(players[AI]:units("RoboSurveyor"))
  if not (surveyor and target) then
    print("AI: no surveyor or no beacon discovered - cannot start mining"); return
  end

  -- 1) survey + drive the surveyor to the nearest beacon we found.
  surveyor:survey(target)
  surveyor:move(target)
  print(string.format("AI: claiming nearest beacon at (%d,%d)", target.x, target.y))

  -- 2) deploy the RoboMiner onto it -> Common Ore Mine.
  at_mark(3, function()
    local miner = first(players[AI]:units("RoboMiner"))
    if miner then miner:deploy(target); print("AI: RoboMiner deploying the mine")
    else print("AI: no RoboMiner to deploy") end
  end)

  -- 3) once the mine has FINISHED construction, run the trucks on a mine<->smelter route.
  when(function()
    local m = first(players[AI]:units("CommonOreMine"))
    return m ~= nil and not m.under_construction
  end, function()
    local mine    = first(players[AI]:units("CommonOreMine"))
    local smelter = first(players[AI]:units("CommonOreSmelter"))
    if mine and smelter then
      local trucks = players[AI]:units("CargoTruck")
      for _, t in ipairs(trucks) do t:mining_route(mine, smelter) end
      print(string.format("AI: mine built - %d Cargo Truck(s) routed to the smelter", #trucks))
      game.message("Enemy mining operation is online.")
    end
  end)
end

-- Build jobs mirror how a HUMAN builds: a ConVec drives to the Structure Factory, docks, and loads a
-- kit from the bay holding it (the ConVecs start EMPTY - no kits conjured onto them), then carries it to
-- a footprint-valid open site and builds. Each step is verified; blocked sites are retried. Only one
-- ConVec loads at the SF at a time (single dock), so jobs queue.  stage: queued -> load -> build.
local jobs = {}

local function bay_with_kit(sf, kind)
  for b = 1, 6 do if sf:factory_cargo(b) == kind then return b end end
  return nil
end

local function site_for(kind, tries)
  local cc = first(players[AI]:units("CommandCenter"))
  return cc and game.find_build_site(kind, { cc.x - (tries + 1) * 7, cc.y - tries * 5 }) or nil
end

-- Queue the structures to build; their kits are pulled from the SF stock by the ConVecs themselves.
local function ai_build_structures()
  local sf      = first(players[AI]:units("StructureFactory"))
  local convecs = players[AI]:units("ConVec")
  if not sf then print("AI: no Structure Factory"); return end
  local plan = { "VehicleFactory", "Nursery" }
  for i, kind in ipairs(plan) do
    local cv = convecs[i]
    if cv then
      local fp = game.footprint(kind)
      print(string.format("AI: queue %s (footprint %dx%d / %dx%d total)", kind, fp.w, fp.h, fp.tw, fp.th))
      jobs[#jobs + 1] = { kind = kind, convec = cv, stage = "queued",
                          baseline = players[AI]:unit_count(kind), tries = 0 }
    end
  end
end

-- Drive the build jobs: load a kit from the SF (one ConVec at a time), then build + verify + retry.
local function tick_jobs()
  if #jobs == 0 then return end
  local sf = first(players[AI]:units("StructureFactory"))
  local loading = false
  for _, j in ipairs(jobs) do if j.stage == "load" then loading = true end end
  local keep = {}
  for _, j in ipairs(jobs) do
    local cv = j.convec
    if not (cv and cv.alive) then
      print("AI: ConVec for " .. j.kind .. " lost - dropping job")

    elseif j.stage == "queued" then
      if (not loading) and sf then              -- claim the single SF dock, one loader at a time
        local bay = bay_with_kit(sf, j.kind)
        if bay then
          j.bay = bay
          cv:dock(sf)                            -- real dock (DoDock fixed): drives in with the dock animation
          j.stage, j.deadline, loading = "load", game.mark() + 16, true
          print(string.format("AI: ConVec -> dock SF for %s kit (bay %d)", j.kind, bay))
        end
      end
      keep[#keep + 1] = j

    elseif j.stage == "load" then
      if cv.kit == j.kind then                  -- kit is aboard -> carry it to a site and build
        local site = site_for(j.kind, 0)
        if site then
          cv:build(site); j.stage, j.deadline = "build", game.mark() + 12
          print(string.format("AI: %s loaded -> building at (%d,%d)", j.kind, site.x, site.y))
        else
          print("AI: " .. j.kind .. " loaded but found no build site")
        end
        keep[#keep + 1] = j
      else
        -- Docked (real dock animation, via the fixed DoDock). Now LOAD the kit. NOTE: the engine's
        -- transfer_cargo (CmdTransferCargo) corrupts the heap and crashes even when properly docked, so
        -- we load with set_kit and empty the bay instead - the kit still leaves the SF's storage.
        local onDock = sf:unit_on_dock()
        if onDock and onDock == cv then
          cv:set_kit(j.kind)                    -- collect the kit while on the dock
          sf:set_factory_cargo(j.bay, "None")   -- ...and remove it from the SF's storage
          print("AI: " .. j.kind .. " kit collected on the SF dock")
          keep[#keep + 1] = j                   -- next tick: cv.kit == kind -> build
        elseif game.mark() >= j.deadline then
          cv:dock(sf); j.deadline, j.tries = game.mark() + 12, j.tries + 1   -- stalled -> re-issue dock
          if j.tries < 6 then keep[#keep + 1] = j else print("AI: gave up loading " .. j.kind) end
        else
          keep[#keep + 1] = j
        end
      end

    elseif j.stage == "build" then
      if players[AI]:unit_count(j.kind) > j.baseline then
        print("AI: " .. j.kind .. " is up")
      elseif game.mark() >= j.deadline then
        if j.tries < 6 then
          local site = site_for(j.kind, j.tries + 1)
          if site then cv:build(site)
            print(string.format("AI: retry build %s at (%d,%d)", j.kind, site.x, site.y)) end
          j.deadline, j.tries = game.mark() + 12, j.tries + 1
          keep[#keep + 1] = j
        else print("AI: gave up building " .. j.kind) end
      else keep[#keep + 1] = j end
    end
  end
  jobs = keep
end

function on_init()
  print("=== AI Sandbox on_init ===")

  game.morale_steady("Good")
  game.message("AI Sandbox: the enemy is establishing a colony. Destroy its Command Center to win.")

  -- Stock every Structure Factory with the standard kit set (mirrors the original mission's
  -- SetFactoryCargo, bays 0-5): Tokamak, Nursery, University, VehicleFactory, RobotCommand, Residence.
  local KITS = { "Tokamak", "Nursery", "University", "VehicleFactory", "RobotCommand", "Residence" }
  for p = 1, 2 do
    local sf = players[p]:units("StructureFactory")[1]
    if sf then
      for bay, kit in ipairs(KITS) do sf:set_factory_cargo(bay, kit) end   -- bays 1..6 (= OP2 bays 0..5)
      print(string.format("player %d: Structure Factory stocked with %d kits", p, #KITS))
    end
  end

  -- Kick off the AI at mark 1 (game time; its units have registered by then).
  at_mark(1, ai_bring_up_mining)
  at_mark(5, ai_build_structures)   -- queue structures (ConVecs are free while mining sets up)
  every(marks(4), tick_jobs)        -- drive each job: dock SF -> load kit -> build -> verify -> retry

  -- Victory / defeat.
  when(function() return not players[AI]:owns_any("CommandCenter") end, function()
    game.message("Enemy Command Center destroyed - you win!")
    mission.win()
  end)
  when(function() return not players[1]:owns_any("CommandCenter") end, function()
    game.message("Your Command Center is gone - you lose.")
    mission.lose()
  end)

  print("=== on_init complete ===")
  return true
end

-- The scheduler drives the AI; on_tick stays light (a heartbeat reporting the AI's progress).
function on_tick()
  if game.tick() % 500 == 0 then   -- every 5 marks (1 mark = 100 ticks)
    print(string.format("heartbeat @ mark %d: mines=%d trucks=%d  VehicleFactory=%d Nursery=%d",
                        game.mark(), players[AI]:unit_count("CommonOreMine"),
                        players[AI]:unit_count("CargoTruck"),
                        players[AI]:unit_count("VehicleFactory"), players[AI]:unit_count("Nursery")))
  end
end
