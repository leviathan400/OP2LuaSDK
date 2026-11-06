# Tug-O-War (Lua)

A **2-player Last One Standing** multiplayer map, and the first multiplayer OP2Lua mission: a remake of
the stock `ml2_31.dll` ("2 Player, LastOne, 'Tug-O-War' map", `on2_02.map`) written from what that
mission does. Its game calls were recorded under different lobby choices with op2missionreader's
`op2dll calls` and compared; no code was taken from the DLL.

Requires an **OP2LuaCore built 2026-11-06 or later** (multiplayer support) and the stock map
`on2_02.map`.

## What it does, like the original

- **Two starts,** north and south, given to the two players at random. Each has a Smelter, Command
  Center, Agridome, Structure Factory, Standard Lab and Tokamak, four Laser Guard Posts at the ends of
  the tube line, and 2 Cargo Trucks, 2 ConVecs, a RoboSurveyor, a RoboMiner and an Earthworker.
- **The lobby decides the rest:**
  - Initial Vehicles: that many Lynx (Laser for Eden, Microwave for Plymouth).
  - Resources: High, Medium or Low colonists, food, ore, research and Structure Factory kits.
  - Day and Night, and Morale Steady.
  - Disasters: an earthquake, electrical storm, vortex or meteor every 120 to 240 marks.
- **The map:** 124 tube tiles and 16 mining beacons, 8 of them with a Bar2 or Bar1 yield rolled each
  game.
- **Win:** Last One Standing, "Eliminate your opponents."

## Files

| File | |
|---|---|
| `TugOWarLua.dll` | the stub, scaffolded with `op2lua-newmission --players 2 --type LastOneStanding`; no `c` prefix, OP2 lists it in the multiplayer lobby |
| `TugOWarLua.placement.lua` | what never changes: the tubes and the fixed beacons (no `players`: the lobby sets them) |
| `TugOWarLua.lua` | the starts, the lobby's settings, the rolled beacons, the disasters and the win |

Copy the three into `OPU\maps\LUA\`, host a multiplayer Last One Standing game, and pick
"2 Player, LastOne, 'Tug-O-War' map (Lua)".

## The log

`OPU\logs\OP2Lua-TugOWarLua.log` records the lobby's settings, each player's colony, resources and
start, and each disaster, for example:

```
Lobby: 2 players; morale steady on, day and night on, disasters on, 2 initial vehicles
Player 1: Eden, human, resources High, north start
Player 2: Plymouth, human, resources High, south start
mark 2: vortex from 27, 30 to 48, 54
```

`DISASTER_MIN, DISASTER_MAX` near the top of `TugOWarLua.lua` set the marks between disasters
(`2, 4` makes one every few marks, for testing).

## Tested

Played in-game on 2026-11-06 by two clients that stayed in sync: the bases, the lobby's vehicles,
Morale Steady, Day and Night, High resources and disasters. Last One Standing (the same call) was seen
working in the Nostalgia sample. Not yet seen in a game: Medium and Low resources.
