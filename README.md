# Outpost 2 Mission Software Development Kit

**Write Outpost 2 missions in Lua - no compiler, no DLL authoring.**

OP2LuaSDK is everything you need to **make your own Outpost 2 missions** in Lua. You do not build
or compile anything - the runtime (`OP2LuaCore.dll`) is prebuilt and included. You write two small
(or large) text files and you have a mission.

| File | What it is |
|---|---|
| `cMyMission.placement.lua` | Players, starting units, resources, beacons, named regions. The starting layout. |
| `cMyMission.lua` | What happens during the mission (timers, attack waves, win/lose, reactions). |

That is the whole job: edit Lua, drop the files in the game, play. Missions are
**multiplayer-safe by construction** (see [`docs/API.md`](docs/API.md)).

---

## What's in this kit

```
OP2LuaSDK/
  README.md                 - you are here
  INSTALL.md                - where files go (Outpost 2 1.4.1 folder layout)
  bin/
    OP2LuaCore.dll          - the prebuilt runtime (drop into OPU). Ships once, runs every mission.
    LuaMission.dll          - the mission stub template (used by the new-mission tools)
  docs/
    API.md                  - the full mission scripting API reference
    GETTING-STARTED.md      - write your first mission, step by step
  samples/                  - five complete, commented missions to play and learn from
    hold-the-line/          - DEFENSE: survive escalating waves
    strike-team/            - OFFENSE: destroy the enemy Command Center
    the-convoy/             - ESCORT: get a cargo truck to safety
    hold-the-beacon/        - CONTROL: hold a region for a set time
    seek-and-destroy/       - HUNT: destroy scattered enemy outposts
  tools/
    op2lua-newmission.exe   - scaffold a new named mission, Windows (DLL + skeleton scripts)
    op2lua-newmission       - the same tool, prebuilt for Linux (x86-64, static). `chmod +x` it.
    new-mission.ps1         - the same scaffolder as a PowerShell script (Windows)
                              (macOS / other: build from source - op2lua-newmission/ in the OP2Lua repo)
```

---

## Quick Start

1. **Install the runtime.** Copy `bin/OP2LuaCore.dll` into your Outpost 2 `OPU` folder
   (see [`INSTALL.md`](INSTALL.md) for the exact path on 1.4.1).
2. **Play a sample.** Copy the three files from a `samples/` folder (e.g. `hold-the-line/`) into
   `OPU\maps\LUA\`, launch Outpost 2, and pick it from the Colony Games list. (A mission lists under
   Colony Games when its `.dll` filename starts with `c` - see [`INSTALL.md`](INSTALL.md).)
3. **Read its `.lua`.** Open `samples/hold-the-line/HoldTheLine.lua` - that's the entire mission.
4. **Make your own.** Run `tools/op2lua-newmission "My First Mission"` (or `tools/new-mission.ps1 -Name "My First Mission"`) and edit the two `.lua`
   files it generates. See [`docs/GETTING-STARTED.md`](docs/GETTING-STARTED.md).

You never open a compiler. The only files you ever edit are `.lua` text files.

---

## Coordinates are the ones you see in-game

When you place a unit, use the coordinates shown on the **in-game status bar** (hover a tile to
read them - the same numbers OP2MissionEditor shows):

```lua
{ type = "Lynx", player = 1, at = { 30, 54 } }   -- appears at 30,54 in-game
```

No offsets to remember - type what you see, the unit lands there.

---

## OP2LuaEditor

A visual editor for building mission layouts. Load a map as the backdrop, place units, draw regions, set mission properties, and save it straight to placement.lua. It also scaffolds new missions (clones + names the stub DLL) so you can go from blank to playable without touching a compiler.

![Screenshot](https://images.outpostuniverse.org/OP2LuaEditor.png)

---

## Multiplayer

Outpost 2 multiplayer is a lockstep simulation, so missions must behave identically on every
player's machine. The SDK makes the safe path the easy path: use the scheduler (`after`/`every`/
`when`), use `game.rand` for randomness, and you're deterministic by default. The full rules are a
short read at the bottom of [`docs/API.md`](docs/API.md).

---

## Misc

- **Full API:** [`docs/API.md`](docs/API.md)
- **Tutorial:** [`docs/GETTING-STARTED.md`](docs/GETTING-STARTED.md)
- **Place layouts visually:** [OP2MissionEditor](https://github.com/leviathan400/OP2MissionEditor) -
  load a map and drag units/structures/beacons/regions into place, then save an `.opm`.
- **Convert `.opm` -> `placement.lua`:** [OP2OpmTools](https://github.com/leviathan400/OP2OpmTools) -
  turns a saved `.opm` into a mission's `placement.lua`.
- **The engine itself** (building `OP2LuaCore.dll`, internals): the separate **OP2Lua** repo.
  You don't need it to make missions.
