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
    { type = "Tiger", player = 1, at = { 15, 53 }, weapon = "ThorsHammer" },
    { type = "Tiger", player = 1, at = { 16, 53 }, weapon = "AcidCloud" },
    { type = "Lynx", player = 1, at = { 15, 54 }, weapon = "Laser" },
    { type = "Lynx", player = 1, at = { 16, 54 }, weapon = "Laser" },
    { type = "Lynx", player = 1, at = { 17, 54 }, weapon = "RailGun" },
    { type = "CommandCenter", player = 1, at = { 3, 60 } },
    { type = "Tokamak", player = 1, at = { 3, 63 } },
    { type = "CommandCenter", player = 2, at = { 37, 37 } },
    { type = "GuardPost", player = 2, at = { 37, 39 }, weapon = "RPG" },
    { type = "CommandCenter", player = 2, at = { 62, 50 } },
    { type = "Tokamak", player = 2, at = { 59, 35 } },
    { type = "GuardPost", player = 2, at = { 59, 49 }, weapon = "RPG" },
    { type = "CommandCenter", player = 2, at = { 50, 57 } },
    { type = "GuardPost", player = 2, at = { 47, 56 }, weapon = "RPG" },
  },

  beacons = {}, walls = {},
  regions = {
    staging = { 13, 51 },
  },
  markers = {
    outpost1 = { type = "Circle", at = { 39, 39 } },
    outpost2 = { type = "Circle", at = { 49, 54 } },
    outpost3 = { type = "Circle", at = { 61, 52 } },
  },
}
