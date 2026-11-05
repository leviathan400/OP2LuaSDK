-- Salvage.placement.lua  -  Salvage  -  starting layout.
-- Blight-survivor scenario: one small base, recover lost technology from wrecks scattered on the map.
-- Coordinates are the ones shown on the in-game status bar (hover a tile to read them).
return {
  name = "Salvage", map = "on4_01.map", tech = "MULTITEK.TXT", type = "Colony",
  max_tech = 12, players_count = 1,

  players = {
    [1] = {
      colony = "Eden", human = true, color = "Blue",
      -- Survivors: lean on resources and population, low tech - the point is to recover it from wrecks.
      resources = { common_ore = 500, rare_ore = 0, food = 800, kids = 4, workers = 10, scientists = 4,
                    tech_level = 4, morale = "Good" },
      center_view = { 28, 56 },
    },
  },

  units = {
    -- The survivor base: a Command Center, a Basic Lab (the salvage turn-in), an Agridome, power, and
    -- the salvage team (2 Scouts to find wrecks, 2 Cargo Trucks to haul them, a ConVec to rebuild).
    { type = "CommandCenter", player = 1, at = { 28, 56 } },
    { name = "lab", type = "BasicLab", player = 1, at = { 25, 57 } },
    { type = "Agridome",      player = 1, at = { 28, 60 } },
    { type = "Tokamak",       player = 1, at = { 31, 57 } },
    { type = "ConVec",        player = 1, at = { 24, 59 } },
    { type = "Scout",         player = 1, at = { 26, 54 } },
    { type = "Scout",         player = 1, at = { 27, 54 } },
    { type = "CargoTruck",    player = 1, at = { 29, 59 } },
    { type = "CargoTruck",    player = 1, at = { 30, 59 } },
  },

  beacons = {
    { type = "MiningBeacon", ore = "Common", at = { 34, 61 } },   -- a little ore so the base can sustain
  },
  walls = {},
  regions = {
    -- The Basic Lab drop-off zone: haul a wreck-laden Cargo Truck in here to recover its technology.
    lab = { 23, 55, 28, 59 },
  },
  markers = {},
}
