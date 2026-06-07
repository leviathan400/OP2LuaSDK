-- Strike Team  (mission.lua)
-- op2-mission
--
-- An OFFENSE mission, the mirror of "Hold the Line": you command a small strike force and must
-- destroy the enemy Command Center to the east. The enemy base "wakes up" the first time your
-- units reach it, and reinforcements arrive for you after a minute.
--
-- placement.lua defines:
--   unit   "enemy_cc"     - the enemy Command Center (destroy it to win)
--   region "enemy_base"   - the area around the enemy base
--   region "muster"       - where your reinforcements arrive
--   players 1 (you) and 2 (the enemy)

function on_init()
  game.morale_steady()
  game.message("STRIKE TEAM: destroy the enemy Command Center to the east!")
 
  at_mark(1, function()
    game.sound("NewMissionObjective")
  end)

  -- The enemy base scrambles defenders the first time YOUR units reach it.
  -- region:units(player) returns the player's units inside the region.
  when(function() return #regions["enemy_base"]:units(players[1]) > 0 end, function()
    game.message("We've been spotted - defenders are scrambling!")
    game.sound("EnemyUnitSighted")
    local defenders = game.create_unit{
      type = "Tiger", player = players[2], at = regions["enemy_reinforcements"], count = 5, weapon = "Microwave",
    }
    for _, t in ipairs(defenders) do t:attack_move(regions["muster"]) end   -- counter-attack westward
  end)

  -- Early reinforcements: 5 Lynx at mark 10 (absolute game time).
  at_mark(10, function()
    game.message("Lynx reinforcements have arrived!")
    game.sound("VehicleReady")
    game.create_unit{ type = "Lynx", player = players[1], at = regions["muster"], count = 5, weapon = "Laser" }
  end)

  -- Reinforcements arrive for you after one minute.
  after(game.minutes(1), function()
    game.message("Reinforcements have arrived at the muster point!")
    game.sound("VehicleReady")
    game.create_unit{ type = "Tiger", player = players[1], at = regions["muster"], count = 3, weapon = "ThorsHammer" }
  end)

  -- Win when the enemy loses their Command Center. Polling ownership with `when` is reliable for
  -- buildings; the on_destroy_unit event is flaky for structures in OP2, so don't depend on it.
  when(function() return not players[2]:owns_any("CommandCenter") end, function()
    game.message("Enemy Command Center destroyed - mission accomplished!")
    game.sound("StructureDestroyed")
    mission.win()
  end)

  -- Lose if your whole strike force is wiped out.
  when(function()
    return not (players[1]:owns_any("Tiger") or players[1]:owns_any("Lynx") or players[1]:owns_any("Panther"))
  end, function()
    game.message("Strike team eliminated. Mission failed.")
    mission.lose()
  end)

  return true
end
