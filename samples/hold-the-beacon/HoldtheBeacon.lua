-- Hold the Beacon  -  capture and control the central hill for a set time.
-- op2-mission
--
-- placement.lua defines:  region "hill" (control point), "enemy_spawn"

local held, GOAL = 0, 30   -- marks of control needed to win

function on_init()
  game.morale_steady()
  game.message(("Capture and hold the central hill for %d marks!"):format(GOAL))
  
  at_mark(1, function()
    game.sound("NewMissionObjective")
  end)
  
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

  -- The enemy assaults every 10 marks - HUNTING your units (attack_move on a unit chases & attacks it),
  -- not advancing on empty ground (attack_move on a region just sieges the spot).
  every(marks(1 * 10), function()
    game.sound("EnemyUnitSighted")
    local a = game.create_unit{ type = "Lynx", player = players[2], at = regions["enemy_spawn"],
                                count = 4, weapon = "Microwave" }
    -- Pick one of your units to hunt: a defender on the hill, else any combat unit (fall back to the hill).
    local function yourTarget()
      local onHill = regions["hill"]:units(players[1])
      if #onHill > 0 then return onHill[1] end
      local tg = players[1]:units("Tiger") ; if #tg > 0 then return tg[1] end
      local lx = players[1]:units("Lynx")  ; if #lx > 0 then return lx[1] end
      return nil
    end
    local tgt = yourTarget()
    for _, t in ipairs(a) do
      if tgt then t:attack_move(tgt) else t:attack_move(regions["hill"]) end
    end
  end)

  -- Lose if your force is wiped out.
  when(function() return not (players[1]:owns_any("Tiger") or players[1]:owns_any("Lynx")) end, function()
    game.message("Your force is destroyed. Mission failed.")
    mission.lose()
  end)
end
