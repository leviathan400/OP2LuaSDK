-- FeatureTest.placement.lua  -  Feature Test  -  exercises the whole OP2Lua *placement* surface.
-- Coordinates are the in-game status-bar coords (hover a tile in OP2 to read them).
-- Pairs with FeatureTest.lua, which exercises the whole *scripting* surface.
return {
  name = "Feature Test", map = "eden01.map", tech = "MULTITEK.TXT", type = "Colony",
  max_tech = 12, players_count = 2,

  -- Two players: a human Eden colony (you) and a computer Plymouth colony (the enemy).
  players = {
    [1] = {
      colony = "Eden", human = true, color = "Blue",
      resources = { common_ore = 5000, rare_ore = 2000, food = 5000,
                    kids = 10, workers = 20, scientists = 12, tech_level = 12, morale = "Good" },
      center_view = { 14, 56 },
    },
    [2] = {
      colony = "Plymouth", human = false, color = "Red", bot = "Balanced",
      resources = { common_ore = 8000, rare_ore = 4000, food = 8000,
                    kids = 30, workers = 40, scientists = 20, tech_level = 12 },
    },
  },

  -- Units: named handles (your_cc / hero / truck / enemy_cc) are referenced from the script.
  units = {
    -- Player 1 (you): a small base, a strike force, and a Cargo Truck (cargo round-trip test).
    { name = "your_cc", type = "CommandCenter", player = 1, at = { 10, 57 } },
    { type = "Agridome",       player = 1, at = { 13, 57 } },
    { type = "Tokamak",        player = 1, at = { 13, 59 } },
    { name = "hero", type = "Tiger",      player = 1, at = { 14, 54 }, weapon = "ThorsHammer" },
    { type = "Lynx",           player = 1, at = { 15, 54 }, weapon = "Laser" },
    { name = "truck", type = "CargoTruck", player = 1, at = { 11, 55 }, cargo = "RareMetal", amount = 1000 },
    { name = "convec", type = "ConVec", player = 1, at = { 12, 53 }, kit = "Agridome" },   -- ConVec kit round-trip (placement 'kit')

    -- Player 2 (enemy AI): the win target plus a couple of defenders.
    { name = "enemy_cc", type = "CommandCenter", player = 2, at = { 56, 40 } },
    { type = "Tokamak",   player = 2, at = { 59, 40 } },
    { type = "GuardPost", player = 2, at = { 54, 38 }, weapon = "RPG" },
    { type = "Lynx",      player = 2, at = { 52, 42 }, weapon = "Laser" },
  },

  beacons = {
    { type = "MiningBeacon", ore = "Common", at = { 8, 58 } },   -- a common-ore mining beacon
  },
  walls = {
    { type = "Wall", at = { 18, 56 } },                          -- a short wall segment
    { type = "Wall", at = { 18, 57 } },
    { type = "Wall", at = { 18, 58 } },
  },

  regions = {
    arena     = { 50, 35, 62, 46 },   -- rectangle around the enemy base
    rally     = { 30, 50 },           -- a point (muster / reinforcement drop)
    trip_zone = { 35, 40, 45, 52 },   -- rectangle trip-wire: walk in to wake the enemy
  },
  markers = {
    north = { at = { 30, 30 } },      -- a named marker (a movement/attack target)
  },
}
