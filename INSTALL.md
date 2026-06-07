# Installing OP2LuaSDK (Outpost 2 1.4.1)

**Requirement:** Outpost 2 with the **OPU unofficial patch (1.4.1)**.

## Install (the easy way)

Extract **`OP2LuaSDK_v0.6.0.zip`** straight into your Outpost 2 install folder (the one with
`Outpost2.exe`). It's laid out to drop everything into place:

```
OPU\OP2LuaCore.dll          <- the shared runtime (ships once, runs every mission)
OPU\maps\LUA\               <- the five sample missions (.dll + .lua + .placement.lua)
```

Then launch Outpost 2, start a **New Colony Game**, and pick a mission from the list.

That's it - the zip mirrors `dist\`, so it puts the runtime and all samples where OP2 expects them.

## Installing your own mission

A mission is **three files that stay together** (same base name), copied into `OPU\maps\LUA\`:

```
cMyMission.dll              <- what OP2 lists in the menu
MyMission.lua               <- the mission logic
MyMission.placement.lua     <- the starting layout
```

> The leading **`c`** on the DLL is what files it under **Colony Games**. The `.lua` files keep the
> plain name - the runtime strips the `c` when it looks for them. A DLL without `c` still runs but
> won't show in the Colony Games list.

## Maps

The samples use **`eden01.map`**, a stock map that ships with Outpost 2 - nothing extra to install.
For a custom `.map`, drop it in `OPU\maps\` (OP2 scans subfolders) and point the mission at it: the
`map = "..."` line in `placement.lua` **and** the map baked into the `.dll`
(`tools/new-mission.ps1 -Map yourmap.map` sets both).

## Logs

Each run writes to `OPU\logs\`:

- `OP2Lua-<MissionName>.log` - your mission's own log: `print(...)` output and any script error
  (with a line number). Look here first when something misbehaves.
- `OP2Lua.log` - the shared engine log across all missions.
