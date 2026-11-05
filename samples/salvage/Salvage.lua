-- Salvage.lua  -  Salvage  -  mission logic.
-- Blight survivors recover lost technology: scout the wastes to FIND wrecks, haul each with a Cargo
-- Truck back to the Basic Lab (the `lab` region) to RECOVER its tech. Win when all wrecks are turned in.
--
-- How OP2 wreckage works here:
--   * game.create_wreckage(at, techId, discovered=false) drops a wreck that's hidden until a unit
--     scouts near it. Driving a Cargo Truck onto a discovered wreck loads it (cargo becomes "Wreckage").
--   * Natively the engine grants the tech when the wreck is turned in at a SPACEPORT; here we script the
--     turn-in at the Basic Lab instead - when a wreck-laden truck enters the `lab` region we grant the
--     tech with player:mark_research and clear the truck's cargo.

function on_init()
  local p = players[1]

  game.message("The Blight consumed our colony. A handful of us crawled out of the wreckage alive.")
  game.message("Salvage the tech wrecks scattered across the wastes - haul each to the Lab to recover it.")
  game.sound("NewMissionObjective")
  game.morale_steady()

  -- The tech wrecks. techId must be 8000-12095 and must match a tech in MULTITEK.TXT.
  local WRECKS = {
    { at = { 60, 20 }, tech = 8104,  name = "Expanded Housing" },
    { at = { 75, 55 }, tech = 8304,  name = "Heat Mining" },
    { at = { 50, 90 }, tech = 8201,  name = "Dual-Turret Weapons Systems" },
    { at = { 12, 75 }, tech = 10204, name = "Solar Power" },
    { at = { 80, 95 }, tech = 8105,  name = "Disaster-Resistant Housing" },
  }
  local total = #WRECKS
  for _, w in ipairs(WRECKS) do
    w.unit = game.create_wreckage(w.at, w.tech, false)   -- hidden until scouted
    print(string.format("[salvage] placed wreck '%s' (tech %d) at (%d,%d)", w.name, w.tech, w.at[1], w.at[2]))
  end
  print(string.format("[salvage] %d tech wrecks placed - find them, haul them to the Lab", total))

  -- DISCOVERY: announce a wreck the first time one of our units gets near it (within 8 tiles).
  every(marks(2), function()
    for _, w in ipairs(WRECKS) do
      if not w.found and w.unit and w.unit.alive then
        for _, u in ipairs(p:units()) do
          local dx, dy = u.x - w.at[1], u.y - w.at[2]
          if dx * dx + dy * dy <= 64 then
            w.found = true
            game.message(string.format("Wreck located: %s. Haul it to the Lab with a Cargo Truck.", w.name))
            print(string.format("[salvage] discovered '%s' at (%d,%d)", w.name, w.at[1], w.at[2]))
            break
          end
        end
      end
    end
  end)

  -- TURN-IN: a wreck disappears from the map when a truck loads it -> remember the tech it's carrying
  -- (FIFO). When a Cargo Truck carrying "Wreckage" enters the lab region, recover the next carried tech.
  local lab = regions["lab"]
  local carried = {}          -- queue of {tech,name} currently being hauled
  local delivered = 0
  local techName = {}
  for _, w in ipairs(WRECKS) do techName[w.tech] = w.name end

  every(marks(1), function()
    -- detect pickups (wreck unit gone)
    for _, w in ipairs(WRECKS) do
      if not w.picked and not (w.unit and w.unit.alive) then
        w.picked = true
        carried[#carried + 1] = { tech = w.tech, name = w.name }
        print(string.format("[salvage] '%s' loaded onto a truck (carrying %d)", w.name, #carried))
      end
    end

    -- detect deliveries (wreck-laden truck inside the lab region)
    if lab and #carried > 0 then
      for _, u in ipairs(p:units("CargoTruck")) do
        if u.alive and u.cargo == "Wreckage" and lab:contains(u) then
          local got = table.remove(carried, 1)
          print(string.format("[salvage] turn-in: truck cargo=%s amount=%d -> granting tech %d (%s)",
            u.cargo, u.cargo_amount, got.tech, got.name))
          u:set_cargo("Empty")              -- unload the wreck
          p:mark_research(got.tech)         -- recover the technology
          delivered = delivered + 1
          game.message(string.format("Technology recovered: %s!  (%d/%d)", got.name, delivered, total))
          game.sound("NewMissionObjective")
          if delivered >= total then
            game.message("Every wreck salvaged - the colony has a future again. Victory!")
            mission.win()
          end
          break   -- one turn-in per tick (one command per unit per tick)
        end
      end
    end
  end)

  -- LOSE: the survivors' Command Center is destroyed.
  when(function() return not p:owns_any("CommandCenter") end, function()
    game.message("The Command Center is lost. The last survivors scatter into the wastes. Mission failed.")
    mission.lose()
  end)

  return true
end
