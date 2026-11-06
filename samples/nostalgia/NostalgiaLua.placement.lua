-- NostalgiaLua.placement.lua  -  4P, LoS, 'Nostalgia', remade in OP2Lua.
-- What the original ml4_43.dll places whatever the lobby chose: its 26 mining beacons. Each corner's
-- base and tubes come with the player who gets that corner, so NostalgiaLua.lua builds them in on_init.
-- No `players` table: in a multiplayer game the lobby has already set each player's colony and colour.
-- Coordinates are the in-game status-bar ones (map file tile + 1).
return {
  name = "4P, LoS, 'Nostalgia' (Lua)", map = "opu_02.map", tech = "MULTITEK.TXT",
  type = "MultiLastOneStanding", max_tech = 12, players_count = 4,

  beacons = {
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "Mid", at = { 15, 8 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "Mid", at = { 120, 8 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "Mid", at = { 15, 124 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "Mid", at = { 120, 124 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "High", at = { 14, 38 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "High", at = { 91, 13 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "High", at = { 114, 92 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "High", at = { 37, 114 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "High", at = { 65, 6 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "High", at = { 122, 65 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "High", at = { 63, 122 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "High", at = { 7, 64 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "High", at = { 51, 57 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "High", at = { 72, 51 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "High", at = { 77, 72 } },
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "High", at = { 56, 78 } },
    { type = "MiningBeacon", ore = "Rare", yield = "Bar1", variant = "Mid", at = { 37, 15 } },
    { type = "MiningBeacon", ore = "Rare", yield = "Bar1", variant = "Mid", at = { 114, 37 } },
    { type = "MiningBeacon", ore = "Rare", yield = "Bar1", variant = "Mid", at = { 91, 114 } },
    { type = "MiningBeacon", ore = "Rare", yield = "Bar1", variant = "Mid", at = { 14, 92 } },
    { type = "MiningBeacon", ore = "Rare", yield = "Bar2", variant = "Mid", at = { 76, 6 } },
    { type = "MiningBeacon", ore = "Rare", yield = "Bar2", variant = "Mid", at = { 122, 76 } },
    { type = "MiningBeacon", ore = "Rare", yield = "Bar2", variant = "Mid", at = { 52, 122 } },
    { type = "MiningBeacon", ore = "Rare", yield = "Bar2", variant = "Mid", at = { 7, 53 } },
    { type = "MiningBeacon", ore = "Rare", yield = "Bar3", variant = "High", at = { 64, 56 } },
    { type = "MiningBeacon", ore = "Rare", yield = "Bar3", variant = "High", at = { 64, 73 } },
  },
}
