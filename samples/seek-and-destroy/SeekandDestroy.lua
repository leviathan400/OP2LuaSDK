-- Seek and Destroy  -  hunt down and destroy all enemy Guard Post's.
-- op2-mission
--
-- placement.lua scatters 3 enemy Guard Posts (the targets) across the map, with markers.

function on_init()
  game.morale_steady()
  game.message("Seek and destroy all 3 enemy Guard Post outposts!")
  
  at_mark(1, function()
    game.sound("NewMissionObjective")
  end)
  
  -- Progress: announce each outpost as it falls. Polling the count is reliable for buildings.
  local remaining = players[2]:unit_count("GuardPost")
  every(marks(2), function()
    local now = players[2]:unit_count("GuardPost")
    if now < remaining then
      remaining = now
      game.sound("StructureDestroyed")
      if now > 0 then game.message(("Outpost destroyed - %d to go."):format(now)) end
    end
  end)

  -- Win when none remain.
  when(function() return players[2]:unit_count("GuardPost") == 0 end, function()
    game.message("All outposts destroyed - mission accomplished!")
    game.sound("StructureDestroyed")
    mission.win()
  end)

  -- Lose if your strike force is wiped out.
  when(function() return not (players[1]:owns_any("Tiger") or players[1]:owns_any("Lynx")) end, function()
    game.message("Strike force eliminated. Mission failed.")
    mission.lose()
  end)
end

