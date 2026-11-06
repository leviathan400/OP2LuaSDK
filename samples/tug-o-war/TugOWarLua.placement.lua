-- TugOWarLua.placement.lua  -  2 Player, LastOne, 'Tug-O-War' map, remade in OP2Lua.
-- What the stock ml2_31.dll places whatever the lobby chose: the tube network and the mining beacons
-- with a fixed ore and yield. Each player's base, resources and research depend on the lobby (which
-- start, the resource level, the starting vehicles), so TugOWarLua.lua builds them in on_init.
-- No `players` table: in a multiplayer game the lobby has already set each player's colony and colour.
-- Coordinates are the in-game status-bar ones (map file tile + 1).
return {
  name = "2 Player, LastOne, 'Tug-O-War' map (Lua)", map = "on2_02.map", tech = "MULTITEK.TXT",
  type = "MultiLastOneStanding", max_tech = 12, players_count = 2,

  walls = {
    { type = "Tube", at = { 9, 50 } }, { type = "Tube", at = { 9, 51 } }, { type = "Tube", at = { 10, 50 } }, { type = "Tube", at = { 11, 50 } },
    { type = "Tube", at = { 12, 23 } }, { type = "Tube", at = { 12, 24 } }, { type = "Tube", at = { 12, 25 } }, { type = "Tube", at = { 12, 26 } },
    { type = "Tube", at = { 12, 27 } }, { type = "Tube", at = { 12, 28 } }, { type = "Tube", at = { 12, 29 } }, { type = "Tube", at = { 12, 30 } },
    { type = "Tube", at = { 12, 31 } }, { type = "Tube", at = { 12, 32 } }, { type = "Tube", at = { 12, 33 } }, { type = "Tube", at = { 12, 34 } },
    { type = "Tube", at = { 12, 35 } }, { type = "Tube", at = { 12, 36 } }, { type = "Tube", at = { 12, 37 } }, { type = "Tube", at = { 12, 38 } },
    { type = "Tube", at = { 12, 39 } }, { type = "Tube", at = { 12, 40 } }, { type = "Tube", at = { 12, 41 } }, { type = "Tube", at = { 12, 42 } },
    { type = "Tube", at = { 12, 43 } }, { type = "Tube", at = { 12, 44 } }, { type = "Tube", at = { 12, 45 } }, { type = "Tube", at = { 12, 46 } },
    { type = "Tube", at = { 12, 47 } }, { type = "Tube", at = { 12, 48 } }, { type = "Tube", at = { 12, 49 } }, { type = "Tube", at = { 12, 50 } },
    { type = "Tube", at = { 13, 23 } }, { type = "Tube", at = { 14, 23 } }, { type = "Tube", at = { 23, 17 } }, { type = "Tube", at = { 24, 17 } },
    { type = "Tube", at = { 25, 17 } }, { type = "Tube", at = { 26, 17 } }, { type = "Tube", at = { 27, 17 } }, { type = "Tube", at = { 28, 17 } },
    { type = "Tube", at = { 29, 17 } }, { type = "Tube", at = { 30, 17 } }, { type = "Tube", at = { 31, 17 } }, { type = "Tube", at = { 32, 17 } },
    { type = "Tube", at = { 33, 17 } }, { type = "Tube", at = { 34, 17 } }, { type = "Tube", at = { 35, 17 } }, { type = "Tube", at = { 36, 13 } },
    { type = "Tube", at = { 36, 14 } }, { type = "Tube", at = { 36, 15 } }, { type = "Tube", at = { 36, 16 } }, { type = "Tube", at = { 36, 17 } },
    { type = "Tube", at = { 37, 13 } }, { type = "Tube", at = { 38, 13 } }, { type = "Tube", at = { 39, 13 } }, { type = "Tube", at = { 40, 13 } },
    { type = "Tube", at = { 41, 13 } }, { type = "Tube", at = { 42, 13 } }, { type = "Tube", at = { 43, 13 } }, { type = "Tube", at = { 44, 13 } },
    { type = "Tube", at = { 45, 13 } }, { type = "Tube", at = { 46, 13 } }, { type = "Tube", at = { 47, 13 } }, { type = "Tube", at = { 48, 13 } },
    { type = "Tube", at = { 49, 13 } }, { type = "Tube", at = { 50, 10 } }, { type = "Tube", at = { 50, 11 } }, { type = "Tube", at = { 50, 12 } },
    { type = "Tube", at = { 50, 13 } }, { type = "Tube", at = { 51, 10 } }, { type = "Tube", at = { 20, 53 } }, { type = "Tube", at = { 20, 54 } },
    { type = "Tube", at = { 20, 55 } }, { type = "Tube", at = { 20, 56 } }, { type = "Tube", at = { 20, 57 } }, { type = "Tube", at = { 20, 58 } },
    { type = "Tube", at = { 21, 53 } }, { type = "Tube", at = { 22, 53 } }, { type = "Tube", at = { 23, 53 } }, { type = "Tube", at = { 24, 53 } },
    { type = "Tube", at = { 25, 53 } }, { type = "Tube", at = { 26, 53 } }, { type = "Tube", at = { 27, 53 } }, { type = "Tube", at = { 28, 53 } },
    { type = "Tube", at = { 29, 53 } }, { type = "Tube", at = { 30, 53 } }, { type = "Tube", at = { 31, 53 } }, { type = "Tube", at = { 32, 53 } },
    { type = "Tube", at = { 33, 53 } }, { type = "Tube", at = { 34, 53 } }, { type = "Tube", at = { 35, 53 } }, { type = "Tube", at = { 36, 53 } },
    { type = "Tube", at = { 37, 53 } }, { type = "Tube", at = { 38, 53 } }, { type = "Tube", at = { 39, 53 } }, { type = "Tube", at = { 40, 52 } },
    { type = "Tube", at = { 40, 53 } }, { type = "Tube", at = { 53, 25 } }, { type = "Tube", at = { 53, 26 } }, { type = "Tube", at = { 53, 27 } },
    { type = "Tube", at = { 53, 28 } }, { type = "Tube", at = { 53, 29 } }, { type = "Tube", at = { 53, 30 } }, { type = "Tube", at = { 53, 31 } },
    { type = "Tube", at = { 53, 32 } }, { type = "Tube", at = { 53, 33 } }, { type = "Tube", at = { 53, 34 } }, { type = "Tube", at = { 53, 35 } },
    { type = "Tube", at = { 53, 36 } }, { type = "Tube", at = { 53, 37 } }, { type = "Tube", at = { 53, 38 } }, { type = "Tube", at = { 53, 39 } },
    { type = "Tube", at = { 53, 40 } }, { type = "Tube", at = { 53, 41 } }, { type = "Tube", at = { 53, 42 } }, { type = "Tube", at = { 53, 43 } },
    { type = "Tube", at = { 53, 44 } }, { type = "Tube", at = { 53, 45 } }, { type = "Tube", at = { 53, 46 } }, { type = "Tube", at = { 53, 47 } },
    { type = "Tube", at = { 53, 48 } }, { type = "Tube", at = { 54, 25 } }, { type = "Tube", at = { 55, 25 } }, { type = "Tube", at = { 56, 25 } },
  },

  -- Eight more beacons get a yield of Bar2 or Bar1 at random each game (TugOWarLua.lua).
  beacons = {
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", at = { 7, 8 } },
    { type = "MiningBeacon", ore = "Rare", yield = "Bar2", at = { 33, 27 } },
    { type = "MiningBeacon", ore = "Rare", yield = "Bar2", at = { 35, 33 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", at = { 57, 57 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar1", at = { 19, 28 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar1", at = { 47, 35 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar3", at = { 52, 18 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar3", at = { 16, 52 } },
  },
}
