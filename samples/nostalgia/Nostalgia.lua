-- Nostalgia.lua  -  Nostalgia (Lua)
--
-- MULTIPLAYER MAP TEMPLATE. This is the clean recreation of the classic "Nostalgia" layout in Lua:
-- the 4-corner base/beacon data lives in Nostalgia.placement.lua; this script holds only the neutral
-- match rules. Deliberately NO AI scripting - keep that in the AISandbox sample. The intent is to grow
-- this into a real multiplayer map (4 corner bases, randomized start locations, human players, a
-- multiplayer DescBlock); see docs/IDEAS.md.
--
-- For now it runs as a 2-player colony game: destroy the enemy Command Center to win.

function on_init()
  print("=== Nostalgia on_init ===")

  game.morale_steady("Good")        -- mirror the original mission's ForceMoraleGood(-1)
  game.message("Nostalgia: last colony standing wins. Destroy the enemy Command Center.")

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

  -- Neutral win/lose (placeholder until a proper last-one-standing multiplayer rule is wired).
  when(function() return not players[2]:owns_any("CommandCenter") end, function()
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

-- No per-tick logic in the template.
function on_tick() end
