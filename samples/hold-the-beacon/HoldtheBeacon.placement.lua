-- placement.lua  -  Hold the Beacon  -  (hand-written sample)
return {
  name = "Hold the Beacon", map = "eden01.map", tech = "MULTITEK.TXT", type = "Colony",
  max_tech = 12, players_count = 2,

  players = {
    [1] = { colony = "Eden", human = true, color = "Blue",
            resources = { common_ore = 3000, food = 3000, kids = 8, workers = 12, scientists = 6, tech_level = 9 },
            center_view = { 35, 50 } },
    [2] = { colony = "Plymouth", human = false, color = "Red",
            resources = { common_ore = 5000, rare_ore = 2000, food = 5000, kids = 20, workers = 30, scientists = 15, tech_level = 12 } },
  },

  units = {
    -- Your force, staged just west of the hill.
    { type = "Tiger", player = 1, at = { 27, 51 }, weapon = "Microwave" },
    { type = "Tiger", player = 1, at = { 28, 51 }, weapon = "Microwave" },
    { type = "Lynx",  player = 1, at = { 27, 52 }, weapon = "Laser" },
    { type = "Lynx",  player = 1, at = { 28, 52 }, weapon = "RPG" },
    { type = "CommandCenter", player = 1, at = { 13, 56 } },
    { type = "Tokamak",       player = 1, at = { 15, 57 } },
    -- Enemy base to the east, attacks the hill.
    { type = "CommandCenter", player = 2, at = { 59, 41 } },
    { type = "Tokamak",       player = 2, at = { 61, 42 } },
    { type = "GuardPost",     player = 2, at = { 57, 43 }, weapon = "RPG" },
  },

  beacons = { { type = "MiningBeacon", ore = "Common", at = { 35, 49 } } },  -- the hill's beacon
  walls = {},
  regions = {
    hill        = { 31, 47, 39, 53 },  -- control this
    enemy_spawn = { 55, 43 },
  },
  markers = {},
}
