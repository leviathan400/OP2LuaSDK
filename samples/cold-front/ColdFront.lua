-- ColdFront.lua  -  Cold Front  -  mission logic.
-- Layout placed in OP2MissionEditor / converted by OP2OpmTools v0.3.1, run on on1_01.map.
-- Edit freely. See docs/API.md.

function on_init()
  -- Startup: log the Plymouth (AI) bot's resources, like the AI Sandbox perception dump.
  local ai = players[2]
  log.ai("=== Cold Front: Plymouth (AI) resources ===")
  log.ai(string.format("  ore=%d rare=%d food=%d  pop=%d (kids=%d workers=%d scientists=%d)",
    ai.ore, ai.rare_ore, ai.food, ai.population, ai.kids, ai.workers, ai.scientists))
  -- Difficulty chosen in the Colony Games menu (use this to make Easy/Normal/Hard variants).
  print(string.format("=== Cold Front: difficulty = %s ===", players[1].difficulty))

  game.message("Cold Front: build up your colony and evacuate to the starship before the volcano consumes you!")
  game.sound("NewMissionObjective")
  game.morale_steady()   -- keep morale stable so it's about the fight, not colony micro

  -- Day/night cycle. DEBUG master toggle: false = full daylight everywhere (no night).
  local DAY_NIGHT_ON = false
  if DAY_NIGHT_ON then
    game.set_daylight_everywhere(false)   -- the moving daylight terminator sweeps the map
    game.set_daylight_moves(true)
    print("[daynight] ENABLED (cycle on)")
  else
    game.set_daylight_everywhere(true)    -- full daylight, no night
    game.set_daylight_moves(false)
    print("[daynight] DISABLED (DAY_NIGHT_ON = false) - full daylight")
  end

  -- DEBUG: AI testing mode - give the human player a big resource head start to test quickly.
  local AI_TEST_DEBUG = true
  if AI_TEST_DEBUG then
    players[1].ore     = 10000
    players[1].food    = 10000
    players[1].workers = 50
    print("[debug] AI_TEST_DEBUG on - player ore=10000 food=10000 workers=50")
  end

  -- DEBUG: echo the scripted AI's events (log.ai) to the in-game comms panel so you can watch the AI
  -- without leaving the game. They always go to the AI log file (OP2Lua-cColdFront-AI.log) regardless.
  local AI_EVENTS_IN_GAME = false
  log.show_ai_in_game(AI_EVENTS_IN_GAME)

  -- Live AI status snapshot: every mark, overwrite OP2Lua-cColdFront-AI-status.json with the Plymouth
  -- AI's current resources + unit counts, for an external monitor to poll.
  every(marks(1), function() log.ai_status(players[2]) end)

  -- DEBUG: log every building as it finishes construction. Pre-mark everything present at start as
  -- "seen" (placement buildings) so only buildings completed DURING the mission get logged.
  local seenBuilt = {}
  for pi = 1, 2 do
    for _, u in ipairs(players[pi]:units()) do
      if u.is_building then seenBuilt[u.id] = true end
    end
  end
  every(marks(1), function()
    for pi = 1, 2 do
      for _, u in ipairs(players[pi]:units()) do
        if u.is_building and u.alive and not u.under_construction and not seenBuilt[u.id] then
          seenBuilt[u.id] = true
          print(string.format("[built] mark %d: player %d %s completed at (%d,%d)",
            game.mark(), pi, u.type, u.x, u.y))
        end
      end
    end
  end)

  -- Remember the two starting Plymouth cargo trucks, so we can tell them from the
  -- VehicleFactory-produced ones later.
  local origTruckIds = {}
  for _, t in ipairs(players[2]:units("CargoTruck")) do origTruckIds[t.id] = true end
  -- Remember the original Earthworker (it lays the main network); the VF-built #2 does its own tubes.
  local origEwId
  for _, e in ipairs(players[2]:units("Earthworker")) do origEwId = e.id; break end

  -- Plymouth (AI): bring the 2-bar mine online, then run the trucks (the AI Sandbox flow).
  -- A mine the AI surveys + deploys is properly docked, so the truck route is valid - routing to a
  -- raw pre-placed CommonOreMine produced a bad dock waypoint and crashed the engine's pathfinder.
  local function first(t) return t[1] end
  local function nearestCommonBeacon(u)
    local best, bestd
    for _, b in ipairs(game.beacons("Common")) do
      local dx, dy = b.x - u.x, b.y - u.y
      local d = dx * dx + dy * dy
      if not bestd or d < bestd then best, bestd = b, d end
    end
    return best
  end

  at_mark(1, function()   -- survey the nearest common beacon (the 2-bar deposit at 22,125)
    local s = first(players[2]:units("RoboSurveyor"))
    if s then local b = nearestCommonBeacon(s); if b then s:survey(b); s:move(b) end end
  end)

  at_mark(5, function()   -- deploy the RoboMiner onto it -> operational mine
    local m = first(players[2]:units("RoboMiner"))
    if m then local b = nearestCommonBeacon(m); if b then m:deploy(b) end end
  end)

  at_mark(30, function()  -- park the surveyor back near base
    local s = first(players[2]:units("RoboSurveyor"))
    if s then s:move({ 33, 117 }) end
  end)

  -- 2nd mine at (58,113): surveyor surveys it at mark 125, a RoboMiner deploys it at mark 129.
  local function commonBeaconAt(ax, ay)
    for _, b in ipairs(game.beacons("Common")) do
      if math.abs(b.x - ax) <= 2 and math.abs(b.y - ay) <= 2 then return b end
    end
  end
  at_mark(125, function()
    local s, b = first(players[2]:units("RoboSurveyor")), commonBeaconAt(58, 113)
    if s and b then s:survey(b); s:move(b); log.ai(string.format("[mine2] mark %d: surveying (58,113)", game.mark()))
    else log.ai("[mine2] mark 125: surveyor or (58,113) beacon missing") end
  end)
  at_mark(129, function()
    local m, b = first(players[2]:units("RoboMiner")), commonBeaconAt(58, 113)
    if m and b then m:deploy(b); log.ai(string.format("[mine2] mark %d: miner deploying mine at (58,113)", game.mark()))
    else log.ai("[mine2] mark 129: miner or (58,113) beacon missing") end
  end)
  at_mark(200, function()   -- reposition the RoboSurveyor
    local s = first(players[2]:units("RoboSurveyor"))
    if s then s:move({ 57, 120 }); log.ai(string.format("[surveyor] mark %d: moving to (57,120)", game.mark())) end
  end)

  when(function()         -- once the mine has finished, route the trucks mine <-> smelter
    local m = first(players[2]:units("CommonOreMine"))
    return m ~= nil and not m.under_construction
  end, function()
    -- Settle a few marks before routing: under the superspeed mod, issuing mining_route the instant the
    -- mine reports "built" can hit a truck dock that isn't fully established yet -> engine route-loop
    -- crash (eip 0047000a, [ecx-0xB80]). See [[op2lua-ai-mine-routing]].
    at_mark(game.mark() + 3, function()
    local mine, smelter = first(players[2]:units("CommonOreMine")), units["ai_smelter"]
    if mine and smelter then
      for _, t in ipairs(players[2]:units("CargoTruck")) do
        if origTruckIds[t.id] then t:mining_route(mine, smelter) end   -- original trucks only
      end
      log.ai("AI: 2-bar mine online - original trucks routed to the smelter")
    end
    end)   -- settle at_mark
  end)

  -- At mark 100, the two NEW (VehicleFactory-built) cargo trucks start mining the deposit -> the new
  -- smelter the AI built at (16,125) (distinct from the original at 16,121).
  local routedTruckIds = {}   -- trucks we've already given a mining route (so later pairs aren't re-grabbed)
  local newTrucksRouted = false
  every(marks(2), function()
    if newTrucksRouted or game.mark() < 100 then return end
    local mine = first(players[2]:units("CommonOreMine"))
    local newSmelter
    for _, s in ipairs(players[2]:units("CommonOreSmelter")) do
      if s.y >= 124 then newSmelter = s; break end   -- new smelter at y~125; original is at y121
    end
    if not (mine and newSmelter) then return end       -- wait until both exist
    local routed = 0
    for _, t in ipairs(players[2]:units("CargoTruck")) do
      if not origTruckIds[t.id] then
        t:mining_route(mine, newSmelter); routedTruckIds[t.id] = true; routed = routed + 1
      end
    end
    if routed > 0 then
      newTrucksRouted = true
      log.ai(string.format("AI: %d new cargo truck(s) mining -> new smelter (mark %d)", routed, game.mark()))
    end
  end)

  -- At mark 260 the 2 newest cargo trucks (built after the 4 Lynx + 2nd Earthworker) mine the 2nd
  -- deposit (58,113) -> the 3rd (common ore) smelter at (52,110).
  at_mark(260, function()
    local mine2, smelter3
    for _, m in ipairs(players[2]:units("CommonOreMine")) do
      if m.x >= 40 then mine2 = m; break end          -- 2nd mine sits east (x~58); first is at x~22
    end
    for _, s in ipairs(players[2]:units("CommonOreSmelter")) do
      if s.x >= 40 then smelter3 = s; break end        -- 3rd smelter is east (x~52); others are at x~16
    end
    if not (mine2 and smelter3) then
      log.ai(string.format("[trucks2] mark %d: 2nd mine/3rd smelter not ready (mine2=%s smelter3=%s)",
        game.mark(), tostring(mine2 ~= nil), tostring(smelter3 ~= nil)))
      return
    end
    local routed = 0
    for _, t in ipairs(players[2]:units("CargoTruck")) do
      if not origTruckIds[t.id] and not routedTruckIds[t.id] then
        t:mining_route(mine2, smelter3); routedTruckIds[t.id] = true; routed = routed + 1
      end
    end
    log.ai(string.format("[trucks2] mark %d: %d new truck(s) mining 2nd mine (%d,%d) -> 3rd smelter (%d,%d)",
      game.mark(), routed, mine2.x, mine2.y, smelter3.x, smelter3.y))
  end)

  -- Once the 4th smelter (52,114) is up (built from mark 400), route the 2 mark-400 cargo trucks:
  -- 2nd mine (58,113) -> 4th smelter. Keep scanning until BOTH are routed - they roll off the VF a few
  -- marks apart, so a one-shot would catch only the first one that exists when the smelter completes.
  local trucks4Count = 0
  every(marks(3), function()
    if trucks4Count >= 2 or game.mark() < 400 then return end
    local mine2, smelter4
    for _, m in ipairs(players[2]:units("CommonOreMine")) do
      if m.x >= 40 then mine2 = m; break end                  -- 2nd (east) mine ~58,113
    end
    for _, s in ipairs(players[2]:units("CommonOreSmelter")) do
      if s.x >= 40 and s.y >= 112 then smelter4 = s; break end -- 4th smelter is the lower east one (52,114)
    end
    if not (mine2 and smelter4) then return end                -- wait until the 4th smelter is built
    for _, t in ipairs(players[2]:units("CargoTruck")) do
      if trucks4Count >= 2 then break end
      if not origTruckIds[t.id] and not routedTruckIds[t.id] then
        t:mining_route(mine2, smelter4); routedTruckIds[t.id] = true; trucks4Count = trucks4Count + 1
        log.ai(string.format("[trucks4] mark %d: truck %d/2 mining 2nd mine (%d,%d) -> 4th smelter (%d,%d)",
          game.mark(), trucks4Count, mine2.x, mine2.y, smelter4.x, smelter4.y))
      end
    end
  end)

  -- ===== Plymouth (AI) base expansion: ConVecs build the new structures (SF makes the kit -> a ConVec
  -- docks the SF and collects it -> carries it to the target and deploys). Two streams share the single
  -- SF dock via a lock: ConVec #1 builds the colony, ConVec #2 builds the 2 RPG guard posts. =====
  local mainQueue = {
    { kind = "CommonOreSmelter",   at = { 16, 125 } },
    { kind = "Residence",          at = { 12, 98 } },
    { kind = "Residence",          at = { 9, 98 } },
    { kind = "MedicalCenter",      at = { 12, 95 } },
    { kind = "MedicalCenter",      at = { 12, 92 } },
    { kind = "Forum",              at = { 9, 95 } },
    { kind = "RecreationFacility", at = { 9, 92 } },
    { kind = "AdvancedLab",        at = { 38, 94 } },
  }
  local rpgQueue = {
    { kind = "GuardPost", at = { 62, 95 },  weapon = "RPG" },
    { kind = "GuardPost", at = { 65, 105 }, weapon = "RPG" },
    { kind = "GuardPost", at = { 45, 92 },  weapon = "EMP" },   -- after the 2 RPG
  }
  local c3Queue = {   -- ConVec #3, started at mark 150
    { kind = "CommonOreSmelter", at = { 52, 110 } },
    { kind = "Tokamak",          at = { 3, 87 } },   -- 3rd tokamak, stacked above the existing two (3,90)/(3,93)
  }
  local agriQueue = {   -- ConVec #2 (the GP convec), from mark 300: 2 agridomes left of the existing (15,113)/(15,116)
    { kind = "Agridome", at = { 11, 113 } },
    { kind = "Agridome", at = { 11, 116 } },
  }
  local mk400Queue = {   -- ConVec #1 (free after the colony), from mark 400: a 4th smelter + a 2nd vehicle factory
    { kind = "CommonOreSmelter", at = { 52, 114 } },   -- under the 3rd smelter (52,110)
    { kind = "VehicleFactory",   at = { 43, 101 } },
  }

  -- placement coord = footprint CENTRE; DoBuild anchor = TOTAL-footprint bottom-right (core-BR + 1).
  local function buildAnchor(kind, cx, cy)
    local fp = game.footprint(kind)
    local w, h = (fp and fp.w) or 1, (fp and fp.h) or 1
    return { cx + math.floor((w - 1) / 2) + 1, cy + math.floor((h - 1) / 2) + 1 }
  end
  -- A `kind` is up at `at` if one stands within a tile of that centre - a per-site check, so two
  -- concurrent same-kind jobs (e.g. both guard-post streams) don't confuse each other via a shared count.
  local function builtAt(kind, at)
    for _, u in ipairs(players[2]:units(kind)) do
      if math.abs(u.x - at[1]) <= 1 and math.abs(u.y - at[2]) <= 1 then return true end
    end
    return false
  end

  local sfBusy = false   -- the SF has one dock: only one ConVec may be loading at a time
  local function runPipeline(name, st, queue, convecIndex)
    local sf = first(players[2]:units("StructureFactory"))
    if not sf then return end

    if not st.cur then
      if st.qi > #queue then return end
      if sfBusy then return end                                  -- another stream holds the dock
      local cv = players[2]:units("ConVec")[convecIndex]
      if not cv then return end
      local job = queue[st.qi]
      sfBusy = true
      sf:set_factory_cargo(1, job.kind, job.weapon)              -- SF makes the kit
      cv:dock(sf)
      st.cur = { kind = job.kind, weapon = job.weapon, at = job.at, cv = cv,
                 stage = "load", deadline = game.mark() + 18, tries = 0 }
      log.ai(string.format("AI[%s]: %s -> SF dock  [%d/%d]", name, job.kind, st.qi, #queue))
      st.qi = st.qi + 1
      return
    end

    local cur, cv = st.cur, st.cur.cv
    if not (cv and cv.alive) then sfBusy = false; st.cur = nil; return end

    if cur.stage == "load" then
      if cv.kit == cur.kind then                                 -- collected -> deploy and free the dock
        cv:build(buildAnchor(cur.kind, cur.at[1], cur.at[2]))
        cur.stage, cur.deadline, sfBusy = "build", game.mark() + 16, false
        log.ai(string.format("AI[%s]: %s deploying at (%d,%d)", name, cur.kind, cur.at[1], cur.at[2]))
      elseif sf:unit_on_dock() == cv then                        -- on the dock -> collect kit, empty the bay
        cv:set_kit(cur.kind, cur.weapon)                         -- weapon = GuardPost topping
        sf:set_factory_cargo(1, "None")
      elseif game.mark() >= cur.deadline then
        cur.tries = cur.tries + 1
        if cur.tries >= 6 then log.ai("AI[" .. name .. "]: gave up loading " .. cur.kind); sfBusy = false; st.cur = nil
        else cv:dock(sf); cur.deadline = game.mark() + 14 end
      end
    elseif cur.stage == "build" then
      if builtAt(cur.kind, cur.at) then
        log.ai(string.format("AI[%s]: %s built at (%d,%d)", name, cur.kind, cur.at[1], cur.at[2]))
        st.cur = nil
      elseif game.mark() >= cur.deadline then
        cur.tries = cur.tries + 1
        if cur.tries >= 6 then log.ai("AI[" .. name .. "]: gave up building " .. cur.kind); st.cur = nil
        else cv:build(buildAnchor(cur.kind, cur.at[1], cur.at[2])); cur.deadline = game.mark() + 16 end
      end
    end
  end

  local mainState, rpgState, c3State, agriState, mk400State =
    { qi = 1 }, { qi = 1 }, { qi = 1 }, { qi = 1 }, { qi = 1 }
  every(marks(3), function()
    runPipeline("main", mainState, mainQueue, 1)   -- ConVec #1 -> the colony
    runPipeline("rpg",  rpgState,  rpgQueue,  2)   -- ConVec #2 -> the 2 RPG guard posts
    if game.mark() >= 150 then
      runPipeline("c3", c3State, c3Queue, 3)       -- ConVec #3 -> smelter (52,110) then 3rd tokamak (3,87)
    end
    if game.mark() >= 300 then
      runPipeline("agri", agriState, agriQueue, 2) -- ConVec #2 (GP convec, now free) -> 2 new agridomes
    end
    if game.mark() >= 400 then
      runPipeline("mk400", mk400State, mk400Queue, 1) -- ConVec #1 (free) -> 4th smelter + 2nd vehicle factory
    end
  end)

  -- Once ConVec #3 has finished its builds it maintains the power plant: repair the most-damaged
  -- Tokamak whenever one is below full health (they take damage / degrade over time).
  every(marks(20), function()
    if c3State.qi <= #c3Queue or c3State.cur then return end   -- ConVec #3 still building
    local cv = players[2]:units("ConVec")[3]
    if not (cv and cv.alive) then return end
    if cv.command == 2 or cv.command == 28 then return end     -- 2=Move (en route), 28=RepairObj (repairing)
    local worst, worstHp
    for _, t in ipairs(players[2]:units("Tokamak")) do
      if t.alive and t.hp < t.max_hp and (not worstHp or t.hp < worstHp) then worst, worstHp = t, t.hp end
    end
    if worst then
      cv:repair(worst)
      log.ai(string.format("[repair] mark %d: ConVec3 repairing Tokamak (hp %d/%d)", game.mark(), worst.hp, worst.max_hp))
    end
  end)

  -- New combat/support vehicles, produced from the Vehicle Factory over time.
  local toMake = {
    { type = "RoboDozer" },
    { type = "RoboMiner" },
    { type = "CargoTruck" }, { type = "CargoTruck" },
    -- the 4 Microwave Lynx hold until mark 100
    { type = "Lynx", weapon = "Microwave", notBefore = 100 }, { type = "Lynx", weapon = "Microwave", notBefore = 100 },
    { type = "Lynx", weapon = "Microwave", notBefore = 100 }, { type = "Lynx", weapon = "Microwave", notBefore = 100 },
    -- after the 4 Microwave Lynx:
    { type = "Earthworker" },
    -- after the 4 Lynx and 2nd Earthworker: 2 more cargo trucks
    { type = "CargoTruck" }, { type = "CargoTruck" },
    { type = "RoboMiner" },
  }
  local mi = 1
  every(marks(12), function()
    if mi > #toMake then return end
    local m = toMake[mi]
    if m.notBefore and game.mark() < m.notBefore then return end   -- hold this one until its mark
    local vf = first(players[2]:units("VehicleFactory"))
    if not vf then return end
    vf:produce(m.type, m.weapon)
    log.ai(string.format("AI: producing %s  [%d/%d] (mark %d)", m.type, mi, #toMake, game.mark()))
    mi = mi + 1
  end)

  -- ===== Plymouth (AI) tube + wall network: laid by the Earthworker over time =====
  -- One line at a time; only issue the next when the Earthworker is free (command 7 = BuildWall).
  local wallJobs = {
    { type = "Tube", rect = { 35, 106, 61, 106 } },   -- south trunk (east half)
    { type = "Tube", rect = { 62, 97, 62, 106 } },    -- east vertical
    { type = "Tube", rect = { 63, 105, 64, 105 } },   -- east spur
    { type = "Tube", rect = { 41, 94, 45, 94 } },     -- north spur
    { type = "Tube", rect = { 45, 95, 45, 105 } },    -- x45 vertical
    { type = "Wall", rect = { 6, 103, 6, 108 } },     -- west gate
    { type = "Wall", rect = { 7, 108, 12, 108 } },
    { type = "Wall", rect = { 12, 103, 12, 107 } },
    { type = "Wall", rect = { 7, 103, 11, 103 } },
    { type = "Wall", rect = { 41, 95, 41, 97 } },     -- north flank
    { type = "Wall", rect = { 36, 97, 40, 97 } },
    { type = "Wall", rect = { 36, 91, 41, 91 } },
    { type = "Wall", rect = { 41, 91, 41, 93 } },
  }
  local wi = 1
  every(marks(3), function()
    if wi > #wallJobs then return end
    local e = first(players[2]:units("Earthworker"))
    if not e then return end
    if e.command == 7 then return end                 -- 7 = BuildWall: still laying; wait
    local j = wallJobs[wi]
    e:build_wall(j.type, j.rect)
    log.ai(string.format("AI: earthworker laying %s line  [%d/%d]", j.type, wi, #wallJobs))
    wi = wi + 1
  end)

  -- Earthworker #2 (the VehicleFactory-built one) lays the tubes feeding the new smelter: (52,107)-(52,108).
  local ew2Done = false
  every(marks(4), function()
    if ew2Done then return end
    local ew2
    for _, e in ipairs(players[2]:units("Earthworker")) do
      if e.alive and e.id ~= origEwId then ew2 = e; break end
    end
    if not ew2 then return end          -- VF hasn't produced it yet
    if ew2.command == 7 then return end -- 7 = BuildWall: still laying; wait
    ew2:build_wall("Tube", { 52, 107, 52, 108 })
    ew2Done = true
    log.ai("[ew2] earthworker 2 laying tube (52,107)-(52,108)")
  end)

  -- ===== Plymouth (AI): the 4 RPG Lynx patrol a loop from mark 15 =====
  -- No native patrol command, so we attack_move along the waypoints and advance to the next when the
  -- group lead gets close - a fighting patrol (engages anything en route). Loops 1 -> 2 -> 3 -> 1.
  local patrolWp  = { { 91, 125 }, { 91, 75 }, { 2, 75 } }
  local rpgLynx   = {}
  local pwi       = 1
  at_mark(15, function()
    for _, l in ipairs(players[2]:units("Lynx")) do
      if l.weapon == "RPG" then rpgLynx[#rpgLynx + 1] = l end
    end
    for _, l in ipairs(rpgLynx) do l:move(patrolWp[pwi]) end   -- move (patrol), not attack-ground the waypoint
    log.ai(string.format("[patrol] mark %d: %d RPG Lynx start -> wp1 (%d,%d)", game.mark(), #rpgLynx, patrolWp[1][1], patrolWp[1][2]))
  end)
  every(marks(2), function()
    if #rpgLynx == 0 then return end
    local lead
    for _, l in ipairs(rpgLynx) do if l.alive then lead = l; break end end
    if not lead then return end                          -- whole patrol wiped
    local wp = patrolWp[pwi]
    local dx, dy = lead.x - wp[1], lead.y - wp[2]
    if dx * dx + dy * dy <= 25 then                      -- within ~5 tiles -> next waypoint
      pwi = pwi % #patrolWp + 1
      local nw = patrolWp[pwi]
      for _, l in ipairs(rpgLynx) do if l.alive then l:move(nw) end end
      -- log.ai(string.format("[patrol] mark %d: reached wp -> wp%d (%d,%d)  lead@(%d,%d)", game.mark(), pwi, nw[1], nw[2], lead.x, lead.y))
    end
  end)

  -- ===== Mark 580: regroup the AI - patrol Lynx, idle ConVecs, and both Earthworkers reposition =====
  at_mark(580, function()
    -- The 4 NEW RPG Lynx (built at mk550) move to (63,100). The patrol's 4 keep patrolling, so pick the
    -- RPG Lynx that are NOT in the patrol group.
    local patrolIds = {}
    for _, l in ipairs(rpgLynx) do patrolIds[l.id] = true end
    local nLynx = 0
    for _, l in ipairs(players[2]:units("Lynx")) do
      if l.alive and l.weapon == "RPG" and not patrolIds[l.id] then l:move({ 63, 100 }); nLynx = nLynx + 1 end
    end
    -- The 2 idle ConVecs (#1 colony, #2 guard posts; #3 still repairs Tokamaks) park near the SF (22,103).
    local cvs = players[2]:units("ConVec")
    if cvs[1] and cvs[1].alive then cvs[1]:move({ 20, 107 }) end
    if cvs[2] and cvs[2].alive then cvs[2]:move({ 24, 107 }) end
    -- The original Earthworker -> (58,90); the VF-built 2nd one -> (45,115).
    for _, e in ipairs(players[2]:units("Earthworker")) do
      if e.alive then
        if e.id == origEwId then e:move({ 58, 90 }) else e:move({ 45, 115 }) end
      end
    end
    log.ai(string.format("[mk580] mark %d: %d RPG Lynx -> (63,100); 2 ConVecs -> near SF; earthworkers -> (58,90)/(45,115)",
      game.mark(), nLynx))
  end)

  -- ===== Plymouth (AI): the 4 base Microwave Lynx run east then fall back, from mark 90 =====
  -- Captured at start as the Microwave Lynx near the base (x<=50), distinct from the forward group.
  local micIds = {}
  for _, l in ipairs(players[2]:units("Lynx")) do
    if l.weapon == "Microwave" and l.x <= 50 then micIds[l.id] = true end
  end
  local micPhase, micDeadline = 0, 0
  local function micEach(fn)
    for _, l in ipairs(players[2]:units("Lynx")) do if micIds[l.id] and l.alive then fn(l) end end
  end
  at_mark(90, function()
    micPhase, micDeadline = 1, game.mark() + 110   -- enough time to cross to (250,50) (~3 tiles/mark)
    micEach(function(l) l:move({ 250, 50 }) end)          -- outbound: plain move (attack_move sieges the empty tile)
    log.ai(string.format("[micrun] mark %d: Microwave Lynx move -> (250,50) (deadline mark %d)",
      game.mark(), micDeadline))
  end)
  every(marks(2), function()
    if micPhase ~= 1 then return end
    local lead
    micEach(function(l) lead = lead or l end)
    if not lead then micPhase = -1; return end            -- group wiped
    local dx, dy = lead.x - 250, lead.y - 50
    local arrived  = (dx * dx + dy * dy <= 49)
    local timedOut = (game.mark() >= micDeadline)
    -- DEBUG: log lead position every tick so we can see how far they get before turning.
    log.ai(string.format("[micrun] mark %d: lead@(%d,%d) dist2=%d", game.mark(), lead.x, lead.y, dx * dx + dy * dy))
    if arrived or timedOut then
      micPhase = 2
      micEach(function(l) l:move({ 57, 90 }) end)         -- return: plain move so they hold, not siege the tile
      log.ai(string.format("[micrun] mark %d: TURN AROUND (%s) lead@(%d,%d) -> move to (57,90)",
        game.mark(), arrived and "ARRIVED at 250,50" or "TIMEOUT", lead.x, lead.y))
    end
  end)

  -- ===== Mark 250: reposition both Microwave Lynx groups =====
  -- The 4 VF-built Microwave Lynx (not the base group, not RPG) move to (59,104);
  -- the base group that ran east and fell back moves up to (59,98).
  at_mark(250, function()
    local newCount, baseCount = 0, 0
    for _, l in ipairs(players[2]:units("Lynx")) do
      if l.alive and l.weapon == "Microwave" then
        if micIds[l.id] then
          l:move({ 59, 98 }); baseCount = baseCount + 1
        else
          l:move({ 59, 104 }); newCount = newCount + 1
        end
      end
    end
    log.ai(string.format("[regroup] mark %d: %d new Lynx -> (59,104), %d returned Lynx -> (59,98)",
      game.mark(), newCount, baseCount))
  end)

  -- Mark 150: the Vehicle Factory builds the 1st Scout.
  at_mark(150, function()
    local vf = first(players[2]:units("VehicleFactory"))
    if vf then vf:produce("Scout"); log.ai(string.format("[mk150] mark %d: VehicleFactory building a Scout", game.mark())) end
  end)

  -- After the 1st Scout: 2 more Scouts (3 total), then 4 Microwave Lynx and 2 EMP Lynx.
  local lateQueue = {
    { type = "Scout" }, { type = "Scout" },
    { type = "Lynx", weapon = "Microwave" }, { type = "Lynx", weapon = "Microwave" },
    { type = "Lynx", weapon = "Microwave" }, { type = "Lynx", weapon = "Microwave" },
    { type = "Lynx", weapon = "EMP" },       { type = "Lynx", weapon = "EMP" },
  }
  local li = 1
  every(marks(12), function()
    if li > #lateQueue or game.mark() < 156 then return end   -- start just after the mark-150 Scout
    local vf = first(players[2]:units("VehicleFactory"))
    if not vf then return end
    local m = lateQueue[li]
    vf:produce(m.type, m.weapon)
    log.ai(string.format("AI: producing %s%s  [late %d/%d] (mark %d)",
      m.type, m.weapon and (" " .. m.weapon) or "", li, #lateQueue, game.mark()))
    li = li + 1
  end)

  -- Mark 400+: the Vehicle Factory builds 2 more cargo trucks. A VF has NO build queue - a produce()
  -- issued while it's still building the previous unit is dropped - so space the calls ~15 marks apart
  -- (a vehicle builds in <12; same cadence as toMake). One truck per cycle until 2 are made.
  local mk400Made = 0
  every(marks(15), function()
    if mk400Made >= 2 or game.mark() < 400 then return end
    local vf = first(players[2]:units("VehicleFactory"))
    if not vf then return end
    vf:produce("CargoTruck"); mk400Made = mk400Made + 1
    log.ai(string.format("[mk400] mark %d: cargo truck %d/2", game.mark(), mk400Made))
  end)

  -- Mark 260: move the 2 (VF-built) EMP Lynx to (59,97).
  at_mark(260, function()
    local n = 0
    for _, l in ipairs(players[2]:units("Lynx")) do
      if l.alive and l.weapon == "EMP" then l:move({ 59, 97 }); n = n + 1 end
    end
    log.ai(string.format("[mk260] mark %d: %d EMP Lynx -> (59,97)", game.mark(), n))
  end)

  -- Mark 550+: build 4 RPG Lynx - 2 from each Vehicle Factory (original + mark-400 2nd VF). A VF drops a
  -- produce() issued while it's still building, so produce one per VF per ~15-mark cycle until 4 are made
  -- (two VFs -> 2 per cycle -> done in two cycles; one VF -> 4 cycles - still gets all 4).
  local mk550Made = 0
  every(marks(15), function()
    if mk550Made >= 4 or game.mark() < 550 then return end
    for _, vf in ipairs(players[2]:units("VehicleFactory")) do
      if mk550Made >= 4 then break end
      vf:produce("Lynx", "RPG"); mk550Made = mk550Made + 1
    end
    log.ai(string.format("[mk550] mark %d: RPG Lynx total %d/4", game.mark(), mk550Made))
  end)

  -- Mark 300: send the 3rd RoboMiner to (43,109). The first two were consumed deploying the mines
  -- (mark 5 and mark 129), so the surviving idle miner is the 3rd one the VF produced.
  at_mark(300, function()
    local miners = players[2]:units("RoboMiner")
    local m = miners[#miners]   -- most recently produced live miner
    if not m then log.ai(string.format("[miner3] mark %d: no RoboMiner alive", game.mark())); return end
    m:move({ 43, 109 })
    log.ai(string.format("[miner3] mark %d: RoboMiner -> (43,109)", game.mark()))
  end)

  -- (The GP ConVec (#2) is repurposed at mark 300 to build 2 new agridomes - see agriQueue above.)

  -- ===== Green Plymouth (player 3, no base): a scripted raiding party =====
  local greenForce, greenDone = {}, false
  at_mark(60, function()
    local emp = game.create_unit{ type = "Lynx", player = players[3], at = { 161, 127 }, count = 2, weapon = "EMP" }
    local mic = game.create_unit{ type = "Lynx", player = players[3], at = { 161, 127 }, count = 4, weapon = "Microwave" }
    for _, u in ipairs(emp) do greenForce[#greenForce + 1] = u end
    for _, u in ipairs(mic) do greenForce[#greenForce + 1] = u end
    log.ai(string.format("[green] mark %d: spawned %d Lynx at (161,127)", game.mark(), #greenForce))
  end)
  at_mark(61, function()   -- 1 mark after the spawn -> move them to (200,1) (move, not attack-ground)
    for _, u in ipairs(greenForce) do if u.alive then u:move({ 200, 1 }) end end
    log.ai(string.format("[green] mark %d: %d Lynx move -> (200,1)", game.mark(), #greenForce))
  end)
  every(marks(2), function()   -- when they reach the top, make them vanish
    if greenDone or #greenForce == 0 then return end
    local lead
    for _, u in ipairs(greenForce) do if u.alive then lead = u; break end end
    if not lead then greenDone = true; return end
    local dx, dy = lead.x - 200, lead.y - 1
    if dx * dx + dy * dy <= 25 then                 -- reached (200,1) -> remove (poof, no explosion)
      for _, u in ipairs(greenForce) do if u.alive then u:remove() end end
      greenDone = true
      log.ai(string.format("[green] mark %d: reached (200,1) - force removed", game.mark()))
    end
  end)

  -- ===== Green Plymouth: a 2nd raiding party at mark 500 (same route: enter, cross, leave) =====
  local green2Force, green2Done = {}, false
  at_mark(500, function()
    local emp = game.create_unit{ type = "Lynx", player = players[3], at = { 161, 127 }, count = 2, weapon = "EMP" }
    local mic = game.create_unit{ type = "Lynx", player = players[3], at = { 161, 127 }, count = 4, weapon = "Microwave" }
    for _, u in ipairs(emp) do green2Force[#green2Force + 1] = u end
    for _, u in ipairs(mic) do green2Force[#green2Force + 1] = u end
    log.ai(string.format("[green2] mark %d: spawned %d Lynx at (161,127)", game.mark(), #green2Force))
  end)
  at_mark(501, function()
    for _, u in ipairs(green2Force) do if u.alive then u:move({ 200, 1 }) end end
    log.ai(string.format("[green2] mark %d: %d Lynx move -> (200,1)", game.mark(), #green2Force))
  end)
  every(marks(2), function()
    if green2Done or #green2Force == 0 then return end
    local lead
    for _, u in ipairs(green2Force) do if u.alive then lead = u; break end end
    if not lead then green2Done = true; return end
    local dx, dy = lead.x - 200, lead.y - 1
    if dx * dx + dy * dy <= 25 then
      for _, u in ipairs(green2Force) do if u.alive then u:remove() end end
      green2Done = true
      log.ai(string.format("[green2] mark %d: reached (200,1) - force removed", game.mark()))
    end
  end)

  -- ===== Lava: the "dormant" volcano wakes and floods the black area =====
  -- Every Slow1 tile (CellType 2 = SlowPassible1, the dark "lava rock") is marked lava-possible so an
  -- eruption can spread across the whole black region; then we trigger the eruption. The vent is the
  -- Slow1 cell nearest the map centre (override `lavaVent` below to fix a specific volcano spot).
  local LAVA_ON = false           -- DEBUG master toggle for the volcano/lava sequence (true = enabled)
  local LAVA_WARN_MARK  = 250     -- the volcano starts to stir
  local LAVA_ERUPT_MARK = 260     -- it blows ~10 marks after the warning
  -- Lava spread speed. OP2's named scale (from DisasterCreator's GetSpreadSpeed): VerySlow 15, Slow 45,
  -- Slower 85, MediumSlow 135, Medium 170, MediumFast 210, Fast 270, Faster 360, VeryFast 440,
  -- Fastest 510, Instant 4096.
  local LAVA_SPEED = 45           -- Slow
  local LAVA_WARN_SPEED = 15      -- VerySlow: the ominous glow that builds at the vent during the warning
  local lavaVent   = { 21, 26 }   -- the "old volcano" vent
  -- Lava only on Slow1 terrain (2 = SlowPassible1, the dark "lava rock") - NOT Med2/etc. But buildings
  -- don't sit on Slow1: the engine turns their tiles into Tube0 (26, "areas under buildings/tubes") and
  -- the cleared ground into DozedArea (21) / Rubble (22). Include those so lava engulfs the base instead
  -- of flowing around it leaving building-shaped islands. (Dozed/Tube cells only flood if adjacent to
  -- Slow1 lava, so bases sitting on other terrain stay safe.)
  local LAVA_TYPES = { [2] = true, [21] = true, [22] = true, [26] = true }
  if not LAVA_ON then
    print("[lava] DISABLED (LAVA_ON = false) - no lava-possible cells marked, no eruption")
  else
    local ms = game.map_size()
    local count = 0
    for y = 1, ms.h do
      for x = 1, ms.w do
        if LAVA_TYPES[game.cell(x, y).type] then
          game.set_lava_possible({ x, y })
          count = count + 1
        end
      end
    end
    print(string.format("[lava] marked %d lava-possible cells (Slow1 + base substrate); vent @ (%d,%d)",
      count, lavaVent[1], lavaVent[2]))
    -- Mark 240: the scientists' early discovery (foreshadows the eruption ~10 marks later).
    at_mark(240, function()
      game.message("Our scientists have discovered that the volcano is NOT dormant!")
      print(string.format("[lava] mark %d: scientists warn the volcano is not dormant", game.mark()))
    end)
    -- WARN: the "dormant" volcano stirs - a slow glow creeps from the vent + a warning to relocate.
    at_mark(LAVA_WARN_MARK, function()
      game.message("WARNING: The old volcano is stirring - relocate your colony!")
      game.create_eruption(lavaVent, LAVA_WARN_SPEED, true)   -- now=true: a small ominous glow builds now
      print(string.format("[lava] mark %d: WARN - volcano stirring at (%d,%d) speed %d",
        game.mark(), lavaVent[1], lavaVent[2], LAVA_WARN_SPEED))
    end)
    -- ERUPT: it blows - the flow accelerates into a violent flood across the lowlands.
    at_mark(LAVA_ERUPT_MARK, function()
      game.set_lava_speed(LAVA_SPEED)                         -- accelerate the existing flow
      game.create_eruption(lavaVent, LAVA_SPEED, true)        -- and re-erupt hard at the vent
      game.message("The volcano ERUPTS! Lava floods the lowlands!")
      print(string.format("[lava] mark %d: ERUPTION at (%d,%d) speed %d - the black area floods",
        game.mark(), lavaVent[1], lavaVent[2], LAVA_SPEED))
    end)
    -- Mark 275: nudge the player toward the relocation out (rebuild a CC, don't just defend).
    at_mark(275, function()
      game.message("Re-establish your Command Center before your last one falls!")
      print(string.format("[lava] mark %d: relocation nudge", game.mark()))
    end)
  end

  -- ===== Starship victory: evacuate resources + colonists to the spacecraft =====
  -- Build a Spaceport and launch cargo rockets / evacuation modules. Each launch is counted by
  -- player:satellite_count(<cargo type>); multiply by the per-rocket amount for the running total.
  -- (Per-rocket amounts are assumptions - the [starship] log prints raw counts so we can calibrate
  -- against the in-game Starship window, then set these exactly.)
  local starshipGoals = {
    { name = "Rare Metals",   cargo = "RareMetalsCargo",   per = 1000, target = 10000 },
    { name = "Common Metals", cargo = "CommonMetalsCargo", per = 1000, target = 10000 },
    { name = "Food",          cargo = "FoodCargo",         per = 1000, target = 10000 },
    { name = "Colonists",     cargo = "EvacuationModule",  per = 100,  target = 200 },
  }
  game.message("STARSHIP: evacuate 10000 Rare Metals, 10000 Common Metals, 10000 Food and 200 Colonists to the spacecraft!")
  local starshipDone, lastCounts = false, {}
  every(marks(2), function()
    if starshipDone then return end
    local me, allMet = players[1], true
    for _, g in ipairs(starshipGoals) do
      local cnt = me:satellite_count(g.cargo)
      if cnt ~= lastCounts[g.cargo] then
        lastCounts[g.cargo] = cnt
        print(string.format("[starship] %s: %d launched (~%d/%d)", g.name, cnt, cnt * g.per, g.target))
      end
      if cnt * g.per < g.target then allMet = false end
    end
    if allMet then
      starshipDone = true
      game.message("The starship is loaded - your colony escapes Cold Front. Victory!")
      game.sound("NewMissionObjective")
      mission.win()
    end
  end)

  -- LOSE: your Command Center is gone.
  when(function() return not players[1]:owns_any("CommandCenter") end, function()
    game.message("Your Command Center is destroyed. Mission failed.")
    mission.lose()
  end)
end
