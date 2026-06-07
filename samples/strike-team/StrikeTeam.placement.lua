-- placement.lua  ──  Strike Team  ──  (hand-written sample; normally generated from a .opm)
-- Your forward base + a strike force to the west; the enemy Command Center to the east.

return {
  name = "Strike Team", map = "eden01.map", tech = "MULTITEK.TXT", type = "Colony",
  max_tech = 12, players_count = 2,

  players = {
    [1] = {
      colony = "Eden", human = true, color = "Blue",
      resources = { common_ore = 3000, food = 3000, kids = 8, workers = 12, scientists = 6, tech_level = 9 },
      center_view = { 15, 54 },
    },
    [2] = {
      colony = "Plymouth", human = false, color = "Red",
      resources = { common_ore = 5000, rare_ore = 2000, food = 5000,
                    kids = 20, workers = 30, scientists = 15, tech_level = 12 },
    },
  },

  units = {
    { type = "CommandCenter", player = 1, at = { 6, 60 } },
    { type = "Agridome", player = 1, at = { 10, 60 } },
    { type = "Tokamak", player = 1, at = { 16, 60 } },
    { type = "Tiger", player = 1, at = { 15, 53 }, weapon = "Laser" },
    { type = "Tiger", player = 1, at = { 16, 53 }, weapon = "Laser" },
    { type = "Tiger", player = 1, at = { 17, 53 }, weapon = "ThorsHammer" },
    { type = "Lynx", player = 1, at = { 15, 54 }, weapon = "Laser" },
    { type = "Lynx", player = 1, at = { 16, 54 }, weapon = "RailGun" },
    { name = "enemy_cc", type = "CommandCenter", player = 2, at = { 59, 36 } },
    { type = "Tokamak", player = 2, at = { 61, 50 } },
    { type = "GuardPost", player = 2, at = { 54, 36 }, weapon = "RPG" },
    { type = "GuardPost", player = 2, at = { 54, 34 }, weapon = "Laser" },
    { type = "Tiger", player = 2, at = { 56, 50 }, weapon = "Microwave" },
  },

  beacons = {
    { type = "MiningBeacon", ore = "Common", at = { 7, 59 } },
  },
  walls = {},

  regions = {
    enemy_base = { 50, 30, 64, 52 },
    muster = { 13, 51 },
    enemy_reinforcements = { 61, 26, 64, 28 },
  },
  markers = {},
}
