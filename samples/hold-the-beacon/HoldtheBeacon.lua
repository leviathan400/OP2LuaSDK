-- Hold the Beacon  -  capture and control the central hill for a set time.
-- op2-mission
--
-- placement.lua defines:  region "hill" (control point), "enemy_spawn"

local held, GOAL = 0, 30   -- marks of control needed to win

function on_init()
  game.message(("Capture and hold the central hill for %d marks!"):format(GOAL))
  game.sound("NewMissionObjective")
  game.morale_steady()

  -- Once per mark: if you hold the hill (your units present, no enemy), tick the counter.
  every(marks(1), function()
    local mine   = #regions["hill"]:units(players[1])
    local theirs = #regions["hill"]:units(players[2])
    if mine > 0 and theirs == 0 then
      held = held + 1
      if held % 10 == 0 then game.message(("Holding the hill... %d/%d"):format(held, GOAL)) end
      if held >= GOAL then
        game.message("Hill secured - mission accomplished!")
        game.sound("StructureCompleted")
        mission.win()
      end
    end
  end)

  -- The enemy assaults the hill every minute.
  every(marks(1 * 60), function()
    game.sound("EnemyUnitSighted")
    local a = game.create_unit{ type = "Tiger", player = players[2], at = regions["enemy_spawn"],
                                count = 4, weapon = "Microwave" }
    for _, t in ipairs(a) do t:attack_move(regions["hill"]) end
  end)

  -- Lose if your force is wiped out.
  when(function() return not (players[1]:owns_any("Tiger") or players[1]:owns_any("Lynx")) end, function()
    game.message("Your force is destroyed. Mission failed.")
    mission.lose()
  end)
end
