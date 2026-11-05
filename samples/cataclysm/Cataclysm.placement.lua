-- Cataclysm.placement.lua  -  Cataclysm  -  starting layout.
-- A single Eden colony on eden01.map, for the disaster director (Cataclysm.lua) to rain havoc on.
-- Coordinates are the ones shown on the in-game status bar (hover a tile to read them).
return {
  name = "Cataclysm", map = "eden01.map", tech = "MULTITEK.TXT", type = "Colony",
  max_tech = 12, players_count = 1,

  players = {
    [1] = {
      colony = "Eden", human = true, color = "Blue",
      resources = { common_ore = 4000, rare_ore = 1000, food = 4000,
                    kids = 10, workers = 18, scientists = 10, tech_level = 12, morale = "Good" },
      center_view = { 14, 56 },
    },
  },

  -- A small spread-out colony - the more it's spread, the more variety of things the disasters hit.
  units = {
    { name = "your_cc", type = "CommandCenter",     player = 1, at = { 12, 56 } },
    { type = "Tokamak",            player = 1, at = { 16, 57 } },
    { type = "Tokamak",            player = 1, at = { 16, 59 } },
    { type = "Agridome",           player = 1, at = {  9, 57 } },
    { type = "Agridome",           player = 1, at = {  9, 59 } },
    { type = "Nursery",            player = 1, at = { 12, 53 } },
    { type = "MedicalCenter",      player = 1, at = { 16, 53 } },
    { type = "Residence",          player = 1, at = { 19, 55 } },
    { type = "Residence",          player = 1, at = { 19, 57 } },
    { type = "StructureFactory",   player = 1, at = { 19, 60 } },
    { type = "VehicleFactory",     player = 1, at = { 23, 57 } },
    { type = "CommonOreSmelter",   player = 1, at = { 23, 60 } },
    { type = "ConVec",             player = 1, at = { 25, 55 } },
    { type = "Lynx",               player = 1, at = { 26, 54 }, weapon = "Laser" },
    { type = "Lynx",               player = 1, at = { 27, 54 }, weapon = "RPG" },
    { type = "CargoTruck",         player = 1, at = { 25, 53 } },
  },

  beacons = {
    { type = "MiningBeacon", ore = "Common", at = { 28, 60 } },
    { type = "MiningBeacon", ore = "Rare",   at = { 6, 50 } },
  },
  walls = {},
  regions = {},
  markers = {},
}
