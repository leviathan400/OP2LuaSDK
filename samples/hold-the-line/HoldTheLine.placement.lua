-- placement.lua  -  GENERATED FROM mission.opm  -  DO NOT EDIT
--
-- This file is produced by OP2MissionEditor (exported from the .opm). It is pure
-- data: where everything starts. The OP2Lua runtime reads this table and applies
-- it before running mission.lua. Coordinates are already in engine space (the
-- converter applied the +31 / -1 offset), and unit defaults are filled in.
--
-- Hand edits will be lost on the next export. Put logic in mission.lua instead.

return {
  -- Mission-list metadata (read during the list scan to fill OP2's DescBlock).
  name     = "Hold the Line",
  map      = "newworld.map",
  tech     = "MULTITEK.TXT",
  type     = "Colony",
  max_tech = 12,
  players_count = 2,

  players = {
    [1] = {
      colony = "Eden", human = true, color = "Blue",
      resources = {
        common_ore = 0, rare_ore = 0, food = 1000,
        kids = 10, workers = 14, scientists = 8,
        tech_level = 0, morale = "Good",
      },
      center_view = { 9, 56 },
    },
    [2] = {
      colony = "Plymouth", human = false, color = "Red", bot = "Balanced",
      resources = { common_ore = 5000, rare_ore = 2000, food = 5000,
                    kids = 20, workers = 30, scientists = 15, tech_level = 12 },
    },
  },

  units = {
    -- Your starting base (player 1)
    { type = "CommandCenter",  player = 1, at = { 10, 56 }, health = 1.0 },
    { type = "Agridome",       player = 1, at = { 13, 56 }, health = 1.0 },
    { type = "Tokamak",        player = 1, at = { 13, 58 }, health = 1.0 },
    { type = "StructureFactory", player = 1, at = { 10, 59 }, health = 1.0 },

    -- The enemy base (player 2). "enemy_cc" is referenced from mission.lua.
    { name = "enemy_cc", type = "CommandCenter", player = 2, at = { 62, 40 }, health = 1.0 },
    { type = "GuardPost", player = 2, at = { 64, 41 }, weapon = "RPG", health = 1.0 },
    { type = "GuardPost", player = 2, at = { 60, 41 }, weapon = "Laser", health = 1.0 },
  },

  beacons = {
    { type = "MiningBeacon", ore = "Common", yield = "Random", variant = "Random", at = { 57, 43 } },
    { type = "MiningBeacon", ore = "Rare",   yield = "Random", variant = "Random", at = { 7, 59 } },
  },

  walls = {},

  -- Named regions referenced from mission.lua (point or { x0,y0, x1,y1 } rect).
  regions = {
    spawn_point = { 62, 46 },
    your_base   = { 7, 53, 17, 61 },
  },

  markers = {},
}
