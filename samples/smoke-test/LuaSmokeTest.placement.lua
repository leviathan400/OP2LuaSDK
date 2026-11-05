-- LuaSmokeTest.placement.lua  -  Smoke Test  -  layout for the full-API smoke test.
-- Pairs with LuaSmokeTest.lua, which exercises (nearly) every OP2Lua binding and tallies pass/fail.
-- Coordinates are the in-game status-bar coords (hover a tile in OP2 to read them).
--
-- The unit set is chosen so each TYPE-SPECIFIC binding can be called on a real unit of that type
-- (a Lab to research on, a Factory to set cargo on, a University to train on, a Cargo Truck to
-- load/unload, a ConVec to build/dock). The two adjacent enemy/ally Lynx provoke combat so the
-- on_damage_unit + on_destroy_unit callbacks fire.
return {
  name = "Lua Smoke Test", map = "eden01.map", tech = "MULTITEK.TXT", type = "Colony",
  max_tech = 12, players_count = 2,

  players = {
    [1] = {
      colony = "Eden", human = true, color = "Blue",
      resources = { common_ore = 9000, rare_ore = 4000, food = 9000,
                    kids = 20, workers = 40, scientists = 25, tech_level = 12, morale = "Good" },
      center_view = { 14, 56 },
    },
    [2] = {
      colony = "Plymouth", human = false, color = "Red", bot = "Balanced",
      resources = { common_ore = 5000, rare_ore = 2000, food = 5000,
                    kids = 15, workers = 25, scientists = 12, tech_level = 12 },
    },
  },

  -- Named handles are referenced from LuaSmokeTest.lua. Buildings spaced out to avoid footprint overlap.
  units = {
    { name = "cc",      type = "CommandCenter", player = 1, at = { 10, 57 } },
    { name = "factory", type = "VehicleFactory", player = 1, at = { 16, 57 } },
    { name = "lab",     type = "StandardLab",    player = 1, at = { 21, 57 } },
    { name = "uni",     type = "University",      player = 1, at = { 10, 61 } },
    { name = "convec",  type = "ConVec",          player = 1, at = { 12, 54 }, kit = "Agridome" },
    { name = "truck",   type = "CargoTruck",      player = 1, at = { 13, 54 }, cargo = "CommonMetal", amount = 500 },
    { name = "tank",    type = "Tiger",           player = 1, at = { 14, 52 }, weapon = "Microwave" },
    { name = "fighter1", type = "Lynx",           player = 1, at = { 15, 52 }, weapon = "Laser" },
    { name = "ew",      type = "Earthworker",     player = 1, at = { 18, 60 } },   -- for build_wall / remove_wall

    { name = "enemy_cc", type = "CommandCenter",  player = 2, at = { 56, 40 } },
    { name = "fighter2", type = "Lynx",           player = 2, at = { 16, 52 }, weapon = "Laser" },  -- adjacent -> combat
  },

  beacons = {
    { type = "MiningBeacon", ore = "Common", at = { 8, 58 } },   -- for game.beacons() / unit.ore
  },
  walls = {},

  regions = {
    home  = { 6, 50, 24, 63 },   -- covers player 1's base (rect) - region:units / :contains tests
    arena = { 50, 35, 62, 46 },  -- around the enemy base (rect)
    rally = { 30, 50 },          -- a point (spawn target for throwaway units)
  },
  markers = {
    north = { at = { 30, 30 } },
  },
}
