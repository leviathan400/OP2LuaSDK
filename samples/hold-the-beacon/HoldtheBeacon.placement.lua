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
    { type = "Tiger", player = 1, at = { 27, 51 }, weapon = "ThorsHammer" },
    { type = "Tiger", player = 1, at = { 28, 51 }, weapon = "ThorsHammer" },
    { type = "Lynx", player = 1, at = { 27, 52 }, weapon = "Laser" },
    { type = "Lynx", player = 1, at = { 28, 52 }, weapon = "RailGun" },
    { type = "CommandCenter", player = 1, at = { 9, 60 } },
    { type = "Tokamak", player = 1, at = { 4, 58 } },
    { type = "CommandCenter", player = 2, at = { 58, 35 } },
    { type = "Tokamak", player = 2, at = { 59, 27 } },
    { type = "GuardPost", player = 2, at = { 53, 35 }, weapon = "RPG" },
  },

  beacons = { { type = "MiningBeacon", ore = "Common", at = { 35, 49 } } },  -- the hill's beacon
  walls = {},
  regions = {
    hill = { 31, 45, 45, 53 },
    enemy_spawn = { 48, 35 },
  },
  markers = {},
}
