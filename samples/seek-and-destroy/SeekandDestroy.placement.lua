-- placement.lua  -  Seek and Destroy  -  (hand-written sample)
return {
  name = "Seek and Destroy", map = "eden01.map", tech = "MULTITEK.TXT", type = "Colony",
  max_tech = 12, players_count = 2,

  players = {
    [1] = { colony = "Eden", human = true, color = "Blue",
            resources = { common_ore = 3000, food = 3000, kids = 8, workers = 12, scientists = 6, tech_level = 9 },
            center_view = { 14, 54 } },
    [2] = { colony = "Plymouth", human = false, color = "Red",
            resources = { common_ore = 4000, food = 4000, kids = 15, workers = 20, scientists = 10, tech_level = 12 } },
  },

  units = {
    -- Your strike force.
    { type = "Tiger", player = 1, at = { 15, 53 }, weapon = "ThorsHammer" },
    { type = "Tiger", player = 1, at = { 16, 53 }, weapon = "Microwave" },
    { type = "Lynx",  player = 1, at = { 15, 54 }, weapon = "Laser" },
    { type = "Lynx",  player = 1, at = { 16, 54 }, weapon = "RPG" },
    { type = "Lynx",  player = 1, at = { 17, 54 }, weapon = "Microwave" },
    { type = "CommandCenter", player = 1, at = { 11, 56 } },
    { type = "Tokamak",       player = 1, at = { 13, 57 } },
    -- Three scattered, powered enemy outposts (each a Guard Post + a CC/Tokamak so it fires).
    { type = "CommandCenter", player = 2, at = { 39, 39 } }, { type = "Tokamak", player = 2, at = { 41, 39 } },
    { type = "GuardPost", player = 2, at = { 40, 41 }, weapon = "RPG" },
    { type = "CommandCenter", player = 2, at = { 57, 41 } }, { type = "Tokamak", player = 2, at = { 59, 41 } },
    { type = "GuardPost", player = 2, at = { 58, 43 }, weapon = "Laser" },
    { type = "CommandCenter", player = 2, at = { 45, 55 } }, { type = "Tokamak", player = 2, at = { 47, 55 } },
    { type = "GuardPost", player = 2, at = { 46, 57 }, weapon = "RPG" },
  },

  beacons = {}, walls = {},
  regions = { staging = { 13, 51 } },
  markers = {
    outpost1 = { type = "Circle", at = { 40, 41 } },
    outpost2 = { type = "Circle", at = { 58, 43 } },
    outpost3 = { type = "Circle", at = { 46, 57 } },
  },
}
