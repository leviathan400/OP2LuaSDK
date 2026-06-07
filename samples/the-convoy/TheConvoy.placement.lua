-- placement.lua  -  The Convoy  -  (hand-written sample; normally generated from a .opm)
return {
  name = "The Convoy", map = "eden01.map", tech = "MULTITEK.TXT", type = "Colony",
  max_tech = 12, players_count = 2,

  players = {
    [1] = { colony = "Eden", human = true, color = "Blue",
            resources = { common_ore = 2000, food = 2000, kids = 8, workers = 12, scientists = 6, tech_level = 8 },
            center_view = { 13, 55 } },
    [2] = { colony = "Plymouth", human = false, color = "Red",
            resources = { common_ore = 4000, food = 4000, kids = 15, workers = 20, scientists = 10, tech_level = 12 } },
  },

  units = {
    -- Your convoy + escort (player 1). "convoy" must survive to the haven.
    { name = "convoy", type = "CargoTruck", player = 1, at = { 11, 55 }, cargo = "RareMetal", amount = 1000 },
    { type = "Lynx", player = 1, at = { 10, 54 }, weapon = "Laser" },
    { type = "Lynx", player = 1, at = { 12, 54 }, weapon = "RPG" },
    { type = "Lynx", player = 1, at = { 11, 53 }, weapon = "Microwave" },
    { type = "CommandCenter", player = 1, at = { 9, 57 } },
    { type = "Tokamak",       player = 1, at = { 12, 58 } },
    -- A couple of enemy units lurking on the route (more ambush via the script).
    { type = "Lynx", player = 2, at = { 33, 51 }, weapon = "Microwave" },
    { type = "Lynx", player = 2, at = { 35, 51 }, weapon = "Microwave" },
  },

  beacons = {}, walls = {},
  regions = {
    haven       = { 55, 45, 63, 53 },  -- reach here to win
    ambush      = { 31, 49 },          -- where enemy ambushers appear
    road        = { 27, 53 },          -- they head for the convoy's route
    lurker_zone = { 25, 43, 43, 59 },  -- entering here wakes the two dormant enemy Lynx
  },
  markers = {},
}
