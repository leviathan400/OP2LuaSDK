# OP2Lua Sample Missions

Ready-to-run example missions for **OP2Lua** (write Outpost 2 missions in Lua - no compiler). Each
folder is a complete mission you can drop into the game, plus a couple of reusable extras. They double
as the worked examples for the scripting API: read the `.lua` to see how a feature is used.

A mission is just three files that share a base name:

| File | What it is |
|---|---|
| `c<Name>.dll` | the mission stub - OP2 lists it; it forwards into `OP2LuaCore.dll`. The leading **`c`** marks it a *colony* game. |
| `<Name>.placement.lua` | the **layout** - players, units, beacons, walls, regions, markers (the "nouns"). |
| `<Name>.lua` | the **logic** - timers, waves, win/lose, reactions (the "verbs"). |

> Note the DLL is `c`-prefixed but the scripts are **not** (`cStrikeTeam.dll` loads `StrikeTeam.lua`).
> OP2 only lists a mission whose DLL filename starts with `c`; the stub strips that `c` to find the
> scripts. **Every sample here ships its DLL already `c`-prefixed**, so all of them are drop-in - copy
> a folder's three files into the game and the mission appears in the menu, no renaming needed.

## How to run a sample

1. Put **`OP2LuaCore.dll`** (from [`../bin/`](../bin)) in your Outpost 2 game folder - the `OPU`
   folder on 1.4.1, or next to `Outpost2.exe` on a slim/1.3.x install. Ships once, runs every mission.
2. Copy a mission's three files into the game's mission folder (`OPU\maps\LUA\` on 1.4.1). Make sure
   the DLL is named `c<Name>.dll` (see the note above).
3. Launch Outpost 2 and pick the mission from the **colony games** list.

Logs land in `OPU\logs\OP2Lua-<MissionDll>.log` (per mission) and `OP2Lua.log` (shared). Each
mission's `print()` output goes to its own log - handy when reading along with the script.

See [`../INSTALL.md`](../INSTALL.md) for full install paths, the OP2Lua **`docs/API.md`** for the
scripting API, and [`../tools/`](../tools) (`new-mission`) to scaffold your own. To convert a mission
laid out in the **OP2MissionEditor**, run its `.opm` through **OP2OpmTools** (Export Lua), which writes
all three files for you.

## The missions

| Folder | Mission | What you do |
|---|---|---|
| `feature-test/` | **Feature Test** | API smoke test (director surface) - spawn/command/scheduler/queries/events. Run it after any core change; if it plays to a win with no crash, that surface is healthy. |
| `smoke-test/` | **Smoke Test** | API smoke test (colony surface) - exercises the economy / perception / engineering / disaster bindings and reports a **PASS/FAIL tally** to the log *and* on-screen (the mission **wins** if all checks pass, **loses** if any fail). Companion to Feature Test; together they cover the full binding surface. (DLL `cLuaSmokeTest.dll`.) |
| `strike-team/` | **Strike Team** | *Offense* - drive a strike force east and destroy the enemy Command Center. |
| `hold-the-line/` | **Hold the Line** | *Defense* - survive escalating waves for 80 marks, or destroy their base. |
| `hold-the-beacon/` | **Hold the Beacon** | *Control* - capture and hold the central hill for a set number of marks. |
| `seek-and-destroy/` | **Seek and Destroy** | *Hunt* - find and destroy all three enemy Guard Post outposts. |
| `the-convoy/` | **The Convoy** | *Escort* - a convoy scenario. |
| `salvage/` | **Salvage** | *Recovery* - haul the tech wrecks scattered across the wastes to your Lab (on4_01.map). |
| `cataclysm/` | **Cataclysm** | *Survival* - weather every disaster and keep your Command Center standing. Demos the disaster director (below). |
| `cold-front/` | **Cold Front** | *Reference mission* - an Eden colony beside a living Plymouth AI on `on1_01.map`, with a volcano threatening your ground; evacuate to orbit via the starship. The fullest showcase (economy AI + disasters + starship victory). Has its own [`README`](cold-front/README.md). |
| `plymouth-cold-war-clone/` | **Plymouth Cold War (Lua clone)** | A faithful Lua port of the classic C++ mission - destroy the entrenched Plymouth Advanced Lab on `eden03.map`. |
| `ai-sandbox/` | **AI Sandbox** | Human colony vs. an **autonomous economy AI** on the 4-corner "Nostalgia" layout - the testbed for the scripted computer player. |
| `nostalgia/` | **Nostalgia** | Last colony standing vs. an *idle* computer colony on the 4-corner layout (ported from the classic C++ mission data). |

## Not a mission

| Folder | What it is |
|---|---|
| `disaster-director/` | A **reusable module** (`disaster-director.lua`), not a playable mission - a weighted/random disaster scheduler (à la Sirbomber's DisasterCreator) in pure Lua. Copy `install_disaster_director(...)` into your own mission's `.lua` and call it once from `on_init()`. `cataclysm/` shows it in action. |
