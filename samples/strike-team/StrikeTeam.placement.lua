-- placement.lua  -  Strike Team  -  (hand-written sample; normally generated from a .opm)
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
    -- Your forward base (player 1)
    { type = "CommandCenter", player = 1, at = { 10, 56 } },
    { type = "Agridome",      player = 1, at = { 13, 56 } },
    { type = "Tokamak",       player = 1, at = { 13, 58 } },
    -- Your strike force (drive these east to the enemy base)
    { type = "Tiger", player = 1, at = { 15, 53 }, weapon = "Microwave" },
    { type = "Tiger", player = 1, at = { 16, 53 }, weapon = "Microwave" },
    { type = "Tiger", player = 1, at = { 17, 53 }, weapon = "ThorsHammer" },
    { type = "Lynx",  player = 1, at = { 15, 54 }, weapon = "Laser" },
    { type = "Lynx",  player = 1, at = { 16, 54 }, weapon = "RPG" },

    -- Enemy base (player 2) - destroy "enemy_cc" to win
    { name = "enemy_cc", type = "CommandCenter", player = 2, at = { 59, 41 } },
    { type = "Tokamak",   player = 2, at = { 61, 43 } },
    { type = "GuardPost", player = 2, at = { 57, 39 }, weapon = "RPG" },
    { type = "GuardPost", player = 2, at = { 61, 39 }, weapon = "Laser" },
    { type = "Tiger",     player = 2, at = { 57, 43 }, weapon = "Microwave" },
    { type = "Tiger",     player = 2, at = { 59, 44 }, weapon = "Microwave" },
  },

  beacons = {
    { type = "MiningBeacon", ore = "Common", at = { 7, 59 } },
  },
  walls = {},

  regions = {
    enemy_base = { 53, 35, 65, 47 },   -- around the enemy base (rect)
    muster     = { 13, 51 },           -- where your reinforcements arrive (point)
  },
  markers = {},
}
