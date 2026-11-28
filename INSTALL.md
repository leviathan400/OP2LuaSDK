# Installing OP2LuaSDK (Outpost 2 1.4.1)

**Requirement:** Outpost 2 with the **OPU unofficial patch (1.4.1)**.

## Install (the easy way)

Extract the **sample pack zip** from the [releases page](https://github.com/leviathan400/OP2LuaSDK/releases)
straight into your Outpost 2 install folder (the one with `Outpost2.exe`). It's laid out to drop everything
into place:

```
OPU\OP2LuaCore.dll          <- the shared runtime (ships once, runs every mission)
OPU\maps\LUA\               <- the sample missions (.dll + .lua + .placement.lua)
```

Then launch Outpost 2, start a **New Colony Game**, and pick a mission from the list.

The sample pack on the releases page is v0.6.0 and carries OP2LuaCore 0.6.0. Replace its `OPU\OP2LuaCore.dll` with
a newer one: the latest release, 0.8.19, from the [OP2Lua releases](https://github.com/leviathan400/OP2Lua/releases),
or this SDK's `bin\`, which has 0.8.20.

From the SDK itself, copy `bin\OP2LuaCore.dll` into `OPU\` and a sample's three files into `OPU\maps\LUA\`.

## Installing your own mission

A mission is **three files that stay together** (same base name), copied into `OPU\maps\LUA\`:

```
cMyMission.dll              <- what OP2 lists in the menu
MyMission.lua               <- the mission logic
MyMission.placement.lua     <- the starting layout
```

> The leading **`c`** on the DLL is what files it under **Colony Games**. The `.lua` files keep the
> plain name - the runtime strips the `c` when it looks for them. A DLL without `c` still runs but
> won't show in the Colony Games list. A multiplayer mission's DLL needs no `c`: the lobby lists it.
> `op2lua-newmission`, `new-mission.ps1` and OP2LuaEditor's New Mission name the files this way.

## Maps

The samples use maps that ship with Outpost 2 and OPU - nothing extra to install. For a custom
`.map`, drop it in `OPU\maps\` (OP2 scans subfolders) and point the mission at it: the
`map = "..."` line in `placement.lua` **and** the map baked into the `.dll`
(`op2lua-newmission --map yourmap.map`, `tools/new-mission.ps1 -Map yourmap.map` or OP2LuaEditor's
Mission Properties set both).

## Logs

Each run writes to `OPU\logs\`:

- `OP2Lua-<MissionDll>.log` (e.g. `OP2Lua-cMyMission.log`) - your mission's own log: `print(...)`
  output and any script error (with a line number). Look here first when something misbehaves.
- `OP2Lua-<MissionDll>-AI.log` - written only when the mission calls `log.ai(...)`.
- `OP2Lua.log` - the shared engine log across all missions.

Every log starts with the running `OP2LuaCore` version and build time; a script can read them with
`game.version()`. To update the runtime, replace `OPU\OP2LuaCore.dll` with a newer one (close the game
first). See [`docs/LOGGING.md`](docs/LOGGING.md).
