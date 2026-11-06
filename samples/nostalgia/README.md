# Nostalgia (Lua)

A **2-4 player Last One Standing** multiplayer map on `opu_02.map`: a remake of OPU's Nostalgia
(`ml4_43.dll`, "4P, LoS, 'Nostalgia' v0.9", first written in C++ with the mission SDK), written from what
that mission does. Its game calls were recorded under different lobby choices with op2missionreader's
`op2dll calls` and compared.

Requires an **OP2LuaCore built 2026-11-06 or later** (multiplayer support) and `opu_02.map`, which OPU
ships in `OPU\maps\Nostalgia\`.

## What it does, like the original

- **A base in each corner:** Command Center, Structure Factory (six kits: Tokamak, Nursery, University,
  Vehicle Factory, Robot Command, Residence), Common Ore Smelter, Tokamak, Standard Lab and Agridome;
  3 ConVecs, 3 Cargo Trucks, a RoboSurveyor, a RoboMiner, an Earthworker, a Microwave Guard Post, and
  the corner's own tubes.
- **Corners given out at random:** one roll picks one of four orders (NW NE SW SE, NE SW SE NW,
  SW SE NW NE, SE NW NE SW), and player n gets the order's nth corner. With 2 players, player 2 gets
  the corner diagonally opposite player 1's.
- **The same start for everyone,** whatever the lobby's resource level or initial vehicles: 6000 ore,
  3000 food, 30 workers, 18 scientists, 22 kids, and research 3303, 3304, 3305 and 3401.
- **From the lobby:** Morale Steady and Day and Night. The day/night band starts at -32 and doesn't move.
- **26 mining beacons,** all fixed (`NostalgiaLua.placement.lua`). No disasters.
- **Win:** Last One Standing, "Eliminate your opponents."

## Files

| File | |
|---|---|
| `NostalgiaLua.dll` | the stub, scaffolded with `op2lua-newmission --players 4 --type LastOneStanding --map opu_02.map`; OP2 lists it in the multiplayer lobby |
| `NostalgiaLua.placement.lua` | the beacons (no `players`: the lobby sets them) |
| `NostalgiaLua.lua` | the corners, the roll, the start, the lobby's settings and the win |

Copy the three into `OPU\maps\Nostalgia\` (beside `opu_02.map`), host a multiplayer Last One Standing
game, and pick "4P, LoS, 'Nostalgia' (Lua)". `OPU\logs\OP2Lua-NostalgiaLua.log` records the lobby's
settings and each player's corner.

## Tested

Played in-game on 2026-11-06 with 2 players: opposite corners (SW against NE), the bases, Morale
Steady and Day and Night. Last One Standing works: the player whose Command Center was destroyed got
the failure message. Not yet seen in a game: 3 or 4 players.
