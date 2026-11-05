-- Cataclysm.lua  -  Cataclysm  -  a disaster showcase / survival demo on eden01.map.
-- Fires one of EVERY disaster type within the first 100 marks so you can see them all quickly.
-- (For a random/weighted ongoing director instead, see samples/disaster-director/disaster-director.lua.)
--
-- NOTE: Colony Games report game.disasters_enabled() == false (there's no disasters toggle in the menu,
-- only Difficulty), so we just call the disaster functions directly - no gate needed. Disaster params
-- use the disaster-director's tested values (meteor size 1, quake magnitude 3, storm/vortex duration 12).

function on_init()
  game.message("Cataclysm: survive every disaster! Keep your Command Center standing.")
  game.sound("NewMissionObjective")
  game.morale_steady()   -- keep morale stable; this is about the disasters, not colony micro

  -- One of each disaster type, spaced across the first ~90 marks, aimed near the base (~12,56).
  at_mark(10, function()
    game.message("DANGER: a meteor is approaching!")
    game.create_meteor({ 18, 52 }, 1)                 -- size 1 = medium
    print("[cataclysm] mark 10: meteor -> (18,52)")
  end)
  at_mark(25, function()
    game.message("Seismic sensors spike - earthquake!")
    game.create_earthquake({ 14, 58 }, 3)             -- magnitude 3
    print("[cataclysm] mark 25: earthquake -> (14,58)")
  end)
  at_mark(40, function()
    game.message("An electrical storm rolls in!")
    game.create_lightning({ 4, 8 }, { 28, 54 }, 12)   -- start, end, duration
    print("[cataclysm] mark 40: lightning (4,8)->(28,54)")
  end)
  at_mark(55, function()
    game.message("A vortex tears across the surface!")
    game.create_tornado({ 40, 10 }, { 8, 58 }, 12)    -- start, end, duration
    print("[cataclysm] mark 55: tornado (40,10)->(8,58)")
  end)
  at_mark(70, function()
    game.message("The ground splits open - a volcanic eruption!")
    game.create_eruption({ 30, 40 }, 45)              -- vent, spreadSpeed (limited without lava terrain)
    print("[cataclysm] mark 70: eruption -> (30,40)")
  end)
  at_mark(85, function()
    game.message("The Blight is spreading!")
    game.create_blight({ 22, 48 }, 50)                -- origin, spreadSpeed
    print("[cataclysm] mark 85: blight -> (22,48)")
  end)

  -- WIN: outlast the cataclysm (survive with a Command Center to mark 200).
  at_mark(200, function()
    if players[1]:owns_any("CommandCenter") then
      game.message("You weathered the Cataclysm. Victory!")
      game.sound("NewMissionObjective")
      mission.win()
    end
  end)

  -- LOSE: your Command Center is destroyed.
  when(function() return not players[1]:owns_any("CommandCenter") end, function()
    game.message("Your Command Center is gone. The colony is lost.")
    mission.lose()
  end)
end
