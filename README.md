# Outpost 2 Mission Software Development Kit

**Write Outpost 2 missions in Lua - no compiler, no DLL authoring.**

OP2LuaSDK is everything you need to **make your own Outpost 2 missions** in Lua. You do not build
or compile anything - the runtime (`OP2LuaCore.dll`) is prebuilt and included. You write two small
(or large) text files and you have a mission.

| File | What it is |
|---|---|
| `MyMission.placement.lua` | Players, starting units, resources, beacons, named regions. The starting layout. |
| `MyMission.lua` | What happens during the mission (timers, attack waves, win/lose, reactions). |

A third file, `cMyMission.dll`, is a ready-made stub the tools write for you; you never compile it.

That is the whole job: edit Lua, drop the files in the game, play. Missions are
**multiplayer-safe by construction** (see [`docs/API.md`](docs/API.md)).

---

## What's in this kit

```
OP2LuaSDK/
  README.md                 - you are here
  INSTALL.md                - where files go (Outpost 2 1.4.1 folder layout)
  LICENSE, THIRD_PARTY_NOTICES.md
  bin/
    OP2LuaCore.dll          - the prebuilt runtime (drop into OPU). Ships once, runs every mission.
    LuaMission.dll          - the mission stub template (used by the new-mission tools)
  docs/
    API.md                  - the full mission scripting API reference
    FILE-FORMAT.md          - the mission files: placement.lua keys, the mission DLL's settings
    GETTING-STARTED.md      - write your first mission, step by step
    LOGGING.md              - the logging/debug standard (Main / Mission / AI logs, in-game AI events)
    CHANGELOG.md            - what each release changed
  samples/                  - complete, commented missions to play and learn from (samples/README.md lists them)
    hold-the-line/          - DEFENSE: survive escalating waves
    strike-team/            - OFFENSE: destroy the enemy Command Center
    the-convoy/             - ESCORT: get a cargo truck to safety
    hold-the-beacon/        - CONTROL: hold a region for a set time
    seek-and-destroy/       - HUNT: destroy scattered enemy outposts
    cold-front/             - COLONY: build, survive a volcanic eruption, evacuate to the starship
                              (living AI base, lava disaster, difficulty, starship victory; see its README.md)
    cataclysm/              - SURVIVAL: keep your Command Center standing through every disaster type
                              (meteor, quake, storm, vortex, eruption, blight) on eden01.map
    salvage/                - RECOVERY: haul tech wrecks to your lab
    plymouth-cold-war-clone/ - a Lua port of the classic C++ mission Plymouth Cold War
    ai-sandbox/             - your colony against a scripted economy AI
    tug-o-war/              - MULTIPLAYER: 2-player Last One Standing, a remake of the stock ml2_31.dll
                              (lobby settings, random starts, disasters; see its README.md)
    nostalgia/              - MULTIPLAYER: 2-4 players, Last One Standing, a remake of ml4_43.dll
    feature-test/, smoke-test/ - API coverage tests (run them after changing the core)
    disaster-director/      - HELPER: a copy-paste random/weighted disaster scheduler (meteor, quake,
                              storm, vortex, lava, blight) with base-targeting and a min-gap timer
  tools/
    OP2LuaEditor.exe        - the visual layout editor (Windows, .NET Framework 4.8), with OP2UtilityDotNet.dll
    op2lua-newmission.exe   - scaffold a new named mission, Windows (DLL + skeleton scripts): map, tech tree,
                              type, players, max tech level, unit-only, AI players. --dll-from <X.placement.lua>
                              rebuilds a mission's DLL from its placement header.
    op2lua-newmission       - the same tool, prebuilt for Linux (x86-64, static). `chmod +x` it.
                              (An older build: --map only, and its DLL lacks the c - rename it c<Name>.dll.)
    new-mission.ps1         - the same tool as a PowerShell script (Windows): the same options (-Map, -Tech,
                              -Type, -Players, -MaxTech, -UnitOnly, -AiPlayers, -DllFrom) and the same files
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
4. **Make your own.** Run `tools/op2lua-newmission "My First Mission"` (or `tools/new-mission.ps1 -Name "My First Mission"`,
   or OP2LuaEditor's File > New Mission) and edit the two `.lua` files it generates. See
   [`docs/GETTING-STARTED.md`](docs/GETTING-STARTED.md).

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

A visual editor for building mission layouts: `tools/OP2LuaEditor.exe` (Windows, .NET Framework 4.8, and an
Outpost 2 1.4.1 install for the map graphics). Load a map as the backdrop, place units, draw regions, set mission
properties, and save it straight to placement.lua. It also scaffolds new missions (clones + names the stub DLL) so
you can go from blank to playable without touching a compiler, and Test in OP2 (F5) starts the game straight
into the open mission.

![Screenshot](https://images.outpostuniverse.org/OP2LuaEditor.png)

A rewrite of the editor in Rust, for Windows, Linux and macOS, is in the OP2Lua repository
(`op2lua-editor-rust/`); it does everything this one does and will replace it here.

---

## Multiplayer

Outpost 2 multiplayer is a lockstep simulation, so missions must behave identically on every
player's machine. The SDK makes the safe path the easy path: use the scheduler (`after`/`every`/
`when`), use `game.rand` for randomness, and you're deterministic by default. The full rules are a
short read at the bottom of [`docs/API.md`](docs/API.md).

---

## Misc

- **Full API:** [`docs/API.md`](docs/API.md)
- **Mission files:** [`docs/FILE-FORMAT.md`](docs/FILE-FORMAT.md)
- **Tutorial:** [`docs/GETTING-STARTED.md`](docs/GETTING-STARTED.md)
- **Place layouts visually:** [OP2MissionEditor](https://github.com/leviathan400/OP2MissionEditor) -
  load a map and drag units/structures/beacons/regions into place, then save an `.opm`.
- **Convert `.opm` -> `placement.lua`:** [OP2OpmTools](https://github.com/leviathan400/OP2OpmTools) -
  turns a saved `.opm` into a mission's `placement.lua`.
- **The engine itself** (building `OP2LuaCore.dll`, internals): the separate **OP2Lua** repo.
  You don't need it to make missions.

---

## License

The SDK (docs, samples, tools and runtime) is released under the [MIT License](LICENSE) -
Copyright © 2026 Outpost Universe. Missions you write with it are yours.

`OP2LuaCore.dll` includes Lua, sol2 and Tethys; their licenses are in
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

*Outpost 2: Divided Destiny* © 1997 Dynamix / Sierra On-Line (rights now held by Activision).
This project is not made or supported by Dynamix, Sierra or Activision.
