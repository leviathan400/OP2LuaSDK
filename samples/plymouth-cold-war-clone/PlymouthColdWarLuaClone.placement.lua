-- PlymouthColdWarLuaClone.placement.lua  -  Plymouth Cold War Lua Clone  -  starting layout.
-- A faithful OP2Lua reproduction of the C++ mission "Plymouth Cold War" (BlackBox / Hooman /
-- Brett208): you (Eden) start a small colony and must take down the entrenched Plymouth base to
-- the east. Layout ported coordinate-for-coordinate from the original for eden03.map.
-- Kept as a reference clone - our own mission is built fresh, not copied.
return {
  name = "Plymouth Cold War Lua Clone", map = "eden03.map", tech = "MULTITEK.TXT", type = "Colony",
  max_tech = 12, players_count = 2,

  players = {
    [1] = { colony = "Eden", human = true, color = "Blue",
            resources = { common_ore = 2500, food = 1200, kids = 8, workers = 17, scientists = 9, tech_level = 9 },
            center_view = { 38, 45 } },
    [2] = { colony = "Plymouth", human = false, color = "Red",
            resources = { common_ore = 4000, food = 4000, kids = 15, workers = 20, scientists = 10, tech_level = 12 } },
  },

  units = {
    -- ===== Your starting Eden colony (player 1) =====
    { type = "CommandCenter",    player = 1, at = { 34, 42 } },
    { type = "CommonOreSmelter", player = 1, at = { 39, 46 } },
    { type = "RoboMiner",        player = 1, at = { 39, 41 } },
    { type = "RoboSurveyor",     player = 1, at = { 37, 41 } },
    { type = "CargoTruck",       player = 1, at = { 41, 41 } },
    { type = "Agridome",         player = 1, at = { 43, 47 } },
    { type = "Tokamak",          player = 1, at = { 31, 53 } },
    { type = "Lynx", player = 1, at = { 38, 37 }, weapon = "Laser" },
    { type = "Lynx", player = 1, at = { 41, 38 }, weapon = "Laser" },
    { type = "Lynx", player = 1, at = { 44, 39 }, weapon = "Laser" },
    { type = "Lynx", player = 1, at = { 45, 41 }, weapon = "RailGun" },

    -- ===== Plymouth stronghold (player 2, AI) =====
    -- Core
    { name = "enemy_cc", type = "CommandCenter", player = 2, at = { 124, 60 } },
    { type = "Agridome",      player = 2, at = { 124, 57 } },
    { type = "StandardLab",   player = 2, at = { 125, 34 } },
    { name = "enemy_lab", type = "AdvancedLab", player = 2, at = { 125, 39 } },   -- destroy this to win
    -- Power
    { type = "Tokamak", player = 2, at = { 87, 59 } },
    { type = "Tokamak", player = 2, at = { 91, 59 } },
    { type = "Tokamak", player = 2, at = { 83, 4 } },
    { type = "Tokamak", player = 2, at = { 87, 4 } },
    { type = "Tokamak", player = 2, at = { 91, 4 } },
    -- Factories + builders
    { type = "StructureFactory", player = 2, at = { 102, 43 } },
    { type = "VehicleFactory",   player = 2, at = { 118, 49 } },
    { type = "VehicleFactory",   player = 2, at = { 115, 45 } },
    { type = "ConVec",      player = 2, at = { 100, 46 } },
    { type = "ConVec",      player = 2, at = { 102, 46 } },
    { type = "ConVec",      player = 2, at = { 104, 46 } },
    { type = "Earthworker", player = 2, at = { 106, 46 } },
    -- Mining
    { type = "CommonOreMine",    player = 2, at = { 92, 53 } },
    { type = "CommonOreMine",    player = 2, at = { 87, 31 } },
    { type = "CommonOreMine",    player = 2, at = { 99, 19 } },
    { type = "CommonOreSmelter", player = 2, at = { 107, 43 } },
    { type = "CommonOreSmelter", player = 2, at = { 107, 39 } },
    { type = "RareOreSmelter",   player = 2, at = { 110, 26 } },
    -- Defenses (powered Guard Posts fire on sight)
    { type = "GuardPost", player = 2, at = { 117, 31 }, weapon = "Stickyfoam" },
    { type = "GuardPost", player = 2, at = { 118, 36 }, weapon = "ESG" },
    { type = "GuardPost", player = 2, at = { 106, 27 }, weapon = "Stickyfoam" },
    { type = "GuardPost", player = 2, at = { 98, 43 },  weapon = "RPG" },
    -- Garrison (Lynx defenders spread across the base)
    { type = "Lynx", player = 2, at = { 94, 15 },  weapon = "Microwave" },
    { type = "Lynx", player = 2, at = { 97, 22 },  weapon = "Microwave" },
    { type = "Lynx", player = 2, at = { 102, 25 }, weapon = "Microwave" },
    { type = "Lynx", player = 2, at = { 107, 30 }, weapon = "Microwave" },
    { type = "Lynx", player = 2, at = { 114, 31 }, weapon = "RPG" },
    { type = "Lynx", player = 2, at = { 112, 34 }, weapon = "RPG" },
    { type = "Lynx", player = 2, at = { 124, 51 }, weapon = "RPG" },
    { type = "Lynx", player = 2, at = { 119, 52 }, weapon = "Microwave" },
    { type = "Lynx", player = 2, at = { 127, 55 }, weapon = "RPG" },
    { type = "Lynx", player = 2, at = { 98, 36 },  weapon = "Microwave" },
    { type = "Lynx", player = 2, at = { 102, 36 }, weapon = "Microwave" },
    { type = "Lynx", player = 2, at = { 100, 49 }, weapon = "Microwave" },
    { type = "Lynx", player = 2, at = { 85, 33 },  weapon = "RPG" },
    { type = "Lynx", player = 2, at = { 88, 49 },  weapon = "Microwave" },
  },

  beacons = {
    -- Under the Plymouth mines (a mine building must sit on a beacon).
    { type = "MiningBeacon", ore = "Common", at = { 92, 53 } },
    { type = "MiningBeacon", ore = "Common", at = { 87, 31 } },
    { type = "MiningBeacon", ore = "Rare",   at = { 99, 19 } },
    -- For you to expand on (west).
    { type = "MiningBeacon", ore = "Common", at = { 33, 32 } },
    { type = "MiningBeacon", ore = "Common", at = { 20, 56 } },
  },

  walls = {
    -- Your colony's tube spur
    { type = "Tube", at = { 37, 42 } }, { type = "Tube", at = { 37, 43 } }, { type = "Tube", at = { 37, 44 } },
    -- Plymouth tube network (connects the stronghold)
    { type = "Tube", at = { 124, 55 } }, { type = "Tube", at = { 124, 54 } }, { type = "Tube", at = { 124, 53 } },
    { type = "Tube", at = { 123, 53 } }, { type = "Tube", at = { 122, 53 } }, { type = "Tube", at = { 121, 53 } },
    { type = "Tube", at = { 121, 52 } }, { type = "Tube", at = { 121, 51 } }, { type = "Tube", at = { 121, 50 } },
    { type = "Tube", at = { 121, 49 } }, { type = "Tube", at = { 112, 46 } }, { type = "Tube", at = { 111, 46 } },
    { type = "Tube", at = { 110, 46 } }, { type = "Tube", at = { 110, 45 } }, { type = "Tube", at = { 110, 44 } },
    { type = "Tube", at = { 110, 43 } }, { type = "Tube", at = { 110, 42 } }, { type = "Tube", at = { 110, 41 } },
    { type = "Tube", at = { 110, 40 } }, { type = "Tube", at = { 110, 39 } }, { type = "Tube", at = { 110, 38 } },
    { type = "Tube", at = { 110, 37 } }, { type = "Tube", at = { 110, 36 } }, { type = "Tube", at = { 110, 35 } },
    { type = "Tube", at = { 110, 34 } }, { type = "Tube", at = { 110, 33 } }, { type = "Tube", at = { 110, 32 } },
    { type = "Tube", at = { 111, 33 } }, { type = "Tube", at = { 112, 33 } }, { type = "Tube", at = { 113, 33 } },
    { type = "Tube", at = { 114, 33 } }, { type = "Tube", at = { 115, 33 } }, { type = "Tube", at = { 116, 33 } },
    { type = "Tube", at = { 117, 33 } }, { type = "Tube", at = { 117, 34 } }, { type = "Tube", at = { 118, 34 } },
    { type = "Tube", at = { 119, 34 } }, { type = "Tube", at = { 120, 34 } }, { type = "Tube", at = { 121, 34 } },
    { type = "Tube", at = { 122, 34 } }, { type = "Tube", at = { 123, 34 } }, { type = "Tube", at = { 125, 36 } },
    { type = "Tube", at = { 125, 37 } }, { type = "Tube", at = { 118, 35 } }, { type = "Tube", at = { 110, 29 } },
    { type = "Tube", at = { 110, 30 } }, { type = "Tube", at = { 110, 31 } }, { type = "Tube", at = { 115, 48 } },
  },

  regions = {
    your_base  = { 28, 36, 48, 56 },
    enemy_base = { 95, 30, 128, 64 },
  },
  markers = {},
}
