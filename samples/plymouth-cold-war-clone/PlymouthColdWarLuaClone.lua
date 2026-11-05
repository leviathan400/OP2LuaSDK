-- PlymouthColdWarLuaClone.lua  -  Plymouth Cold War Lua Clone  -  mission logic.
-- A faithful OP2Lua reproduction of the C++ "Plymouth Cold War": grow your Eden colony and destroy
-- the Plymouth Advanced Lab to the east. Lose if your Command Center falls.
-- Reference clone - our own mission is built fresh, not copied. See docs/API.md for the full API.

local reinforced = false

function on_init()
  game.message("Plymouth Cold War: build up your colony and destroy the Plymouth Advanced Lab!")
  game.sound("NewMissionObjective")

  -- Moving day/night line (a real colony game - light your vehicles and structures).
  game.set_daylight_everywhere(false)
  game.set_daylight_moves(true)

  -- Milestone: once you get a mining operation going and bank some ore, reinforcements arrive
  -- (a ConVec with a Structure Factory kit) so you can expand toward the enemy.
  when(function() return players[1].ore >= 3000 end, function()
    if reinforced then return end
    reinforced = true
    game.message("Reinforcements have arrived - expand the colony!")
    game.sound("NewMissionObjective")
    local r = game.create_unit{ type = "ConVec", player = players[1], at = { 36, 40 } }
    for _, u in ipairs(r) do u:set_kit("StructureFactory"); u:set_lights(true) end
  end)

  -- WIN: the Plymouth Advanced Lab is destroyed.
  when(function() return not players[2]:owns_any("AdvancedLab") end, function()
    game.message("Plymouth Advanced Lab destroyed - mission accomplished!")
    game.sound("StructureDestroyed")
    mission.win()
  end)

  -- LOSE: your Command Center is gone.
  when(function() return not players[1]:owns_any("CommandCenter") end, function()
    game.message("Your Command Center is destroyed. The colony is lost.")
    mission.lose()
  end)

  return true
end
