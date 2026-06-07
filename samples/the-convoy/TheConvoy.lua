-- The Convoy  -  escort the cargo truck east to the haven, keeping it alive.
-- op2-mission
--
-- placement.lua defines:  unit "convoy", region "haven" (goal), "ambush"/"road" (enemy spawns)

function on_init()
  game.morale_steady()
  game.message(("Escort the convoy (%d %s) east to the haven - keep it alive!")
                 :format(units["convoy"].cargo_amount, units["convoy"].cargo))
                 
   at_mark(1, function()
    game.sound("NewMissionObjective")
  end)
  
  -- Win when the convoy reaches the haven.
  when(function() return regions["haven"]:contains(units["convoy"]) end, function()
    game.message("The convoy reached the haven - mission accomplished!")
    game.sound("StructureCompleted")
    mission.win()
  end)

  -- Lose if the convoy is destroyed.
  when(function() return not units["convoy"].alive end, function()
    game.message("The convoy was destroyed. Mission failed.")
    mission.lose()
  end)

  -- The two pre-placed enemy Lynx sit dormant until your convoy enters their territory -
  -- then they wake up and hunt it. (when() fires once, so this is a clean one-shot trip-wire.)
  when(function() return #regions["lurker_zone"]:units(players[1]) > 0 end, function()
    game.message("Enemy units sighted - they're moving to engage!")
    game.sound("EnemyUnitSighted")
    for _, e in ipairs(players[2]:units("Lynx")) do e:attack_move(units["convoy"]) end
  end)

  -- Two scripted ambushes along the route.
  local function ambush(mark, count)
    at_mark(mark, function()
      game.message("Ambush!")
      game.sound("WeAreUnderAttack")
      local a = game.create_unit{ type = "Lynx", player = players[2], at = regions["ambush"],
                                  count = count, weapon = "Microwave" }
      -- Send them after the convoy itself. Your escort will have to intercept.
      for _, t in ipairs(a) do t:attack_move(units["convoy"]) end
    end)
  end
  ambush(8, 2)
  ambush(15, 3)
end
