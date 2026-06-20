# OP2Lua Sample Missions

Ready-to-run example missions for **OP2Lua**.
Each folder is a complete mission you can drop into the game, plus a couple of reusable extras.
They double as the worked examples for the scripting API: read the `.lua` to see how a feature is used.

A mission is just three files that share a base name:

| File | What it is |
|---|---|
| `c<Name>.dll` | the mission stub - OP2 lists it; it forwards into `OP2LuaCore.dll`. The leading **`c`** marks it a *colony* game. |
| `<Name>.placement.lua` | the **layout** - players, units, beacons, walls, regions, markers (the "nouns"). |
| `<Name>.lua` | the **logic** - timers, waves, win/lose, reactions (the "verbs"). |
