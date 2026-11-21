# OP2Lua Mission File Format

The files an OP2Lua mission is made of, what OP2LuaCore reads from each, and in what order. This is the reference
for `<Mission>.placement.lua`; the functions a mission script calls are in [API.md](API.md). As of v0.8.5.

## The files

A mission is three files side by side in the game's `OPU\maps` folder (or a folder under it, such as `maps\LUA`),
plus the map it plays on:

| File | What it is | Who reads it |
|---|---|---|
| `<Mission>.dll` | A copy of the mission stub (`LuaMission.dll`) with the mission's name, map, type and player count patched in. The code is the same in every mission: it hands every call on to `OP2LuaCore.dll`. | Outpost 2 (the mission list, then the game) |
| `<Mission>.placement.lua` | Data: players, starting units, beacons, walls, regions and markers. | OP2LuaCore, when the mission starts |
| `<Mission>.lua` | Logic: the callbacks and scheduled events. | OP2LuaCore, when the mission starts |
| `<map>.map` | The map named in the DLL (a stock map, or one shipped with the mission). | Outpost 2 |

`OP2LuaCore.dll` itself sits in the `OPU` folder, shared by every mission.

`op2lua-newmission` and OP2LuaEditor's New Mission write all three files; OP2LuaEditor edits the placement and
the DLL's settings afterwards.

### How the scripts are found

The stub passes its own folder and file name (without `.dll`) to the core. For a DLL named `<base>.dll` the core
takes the first file that exists of:

| Placement | Script |
|---|---|
| `<base>.placement.lua` | `<base>.lua` |
| `<alt>.placement.lua` | `<alt>.lua` |
| `placement.lua` | `mission.lua` |

`<alt>` is `<base>` without a leading `c` that comes before a capital letter: Outpost 2 lists a DLL whose name
starts with `c` under colony games, and the scripts need no such prefix (`cStrikeTeam.dll` finds
`StrikeTeam.lua`). A name like `convoy` keeps its `c`.

With no placement file the mission runs script-only (the log notes it), and `players[]` still holds every player
in the game. A missing script, or one with an error, is reported in a message box and the log; the placement is still applied,
but no callback runs.

## The mission DLL

Outpost 2 reads these exports from the DLL before any Lua runs, so they, not the placement's header, decide what
the mission list shows and which map loads:

| Export | Type | Meaning |
|---|---|---|
| `LevelDesc` | `char[1024]` | The name in the mission list. |
| `MapName` | `char[1024]` | The `.map` file the game loads. |
| `TechtreeName` | `char[1024]` | The tech tree file (`MULTITEK.TXT` for the standard tree). |
| `DescBlock` | 4 ints | `missionType`, `numPlayers`, `maxTechLevel`, `unitMission`. |
| `DescBlockEx` | struct | Extended settings; all zero in the stub. |

`missionType` is the list the mission appears under:

| Value | Placement `type` | Listed as |
|---|---|---|
| 1 .. 12 | `"1"` .. `"12"` (as op2dll writes them) | Campaign mission 1 .. 12 |
| -1 | `Colony` | Colony game |
| -2 | `AutoDemo` | Demo |
| -3 | `Tutorial` | Tutorial |
| -4 | `MultiLandRush` (`LandRush`) | Multiplayer: Land Rush |
| -5 | `MultiSpaceRace` (`SpaceRace`) | Multiplayer: Space Race |
| -6 | `MultiResourceRace` (`ResourceRace`) | Multiplayer: Resource Race |
| -7 | `MultiMidas` (`Midas`) | Multiplayer: Midas |
| -8 | `MultiLastOneStanding` (`LastOneStanding`) | Multiplayer: Last One Standing |

`numPlayers` is 1 to 6. On a multiplayer type it is the number of human players and the lobby sets up each one;
on the other types it counts every player, computer players included. `maxTechLevel` is 12 for the whole tree.
`unitMission` 1 turns off most reports.

The stub also exports the usual mission entry points (`InitProc`, `AIProc`, `GetSaveRegions`, the `On*` hooks)
and a do-nothing `OP2LuaTrigger`, which the core's own triggers name.

To change the name, map, type or player count, patch the DLL: OP2LuaEditor's Mission Properties does it, and so
does `op2lua-newmission` (`--map`, `--type`, `--players`; the SDK's older Linux build has `--map` only) for a new
mission.

## Coordinates

A coordinate in a placement file is a **status-bar coordinate**: the numbers Outpost 2 shows for the tile
under the mouse, 1-based, the ones OP2MissionEditor and OP2LuaEditor show too. The core converts them to the
game's own grid (which has a hidden 32-tile margin on maps narrower than 512) when it applies the placement.

| Form | Meaning |
|---|---|
| `{ x, y }` or `{ x =, y = }` | A tile. |
| `{ x =, y =, raw = true }` | The game's own tile (0-based, with the hidden margin), used as it is: a stock mission's tile off the map, say. Not for regions. |
| `{ x1, y1, x2, y2 }` | A rectangle, both corners included (regions only). The corners may come in either order. |

The conversion of a status-bar tile wraps: a coordinate past the edge lands on the other side of the map (x by
the map's width mask, y by its height). A raw tile isn't converted, so it isn't wrapped either. (Script calls
don't wrap status-bar tiles; see API.md, Coordinates.)

## `<Mission>.placement.lua`

An ordinary Lua chunk that **returns one table**. Anything else (a syntax error, or no table returned) is
reported in a message box and the log, and the mission runs with no placement.

```lua
return {
  -- header: for the tools and the author (see below)
  name = "Hold the Line", map = "eden01.map", tech = "MULTITEK.TXT",
  type = "Colony", max_tech = 12, players_count = 2,

  players = {
    [1] = { colony = "Eden", human = true, color = "Blue",
            resources = { common_ore = 2000, food = 1000, kids = 10, workers = 14, scientists = 8 },
            center_view = { 9, 56 } },
    [2] = { colony = "Plymouth", human = false, color = "Red" },
  },

  units = {
    { name = "enemy_cc", type = "CommandCenter", player = 2, at = { 93, 39 } },
    { type = "Tiger", player = 2, at = { 95, 40 }, weapon = "Microwave", direction = "West" },
    { type = "CargoTruck", player = 1, at = { 11, 55 }, cargo = "Food", amount = 500 },
    { type = "ConVec", player = 1, at = { 12, 55 }, kit = "GuardPost", kit_topping = "Laser" },
  },

  beacons = {
    { type = "MiningBeacon", ore = "Common", yield = "Bar2", variant = "Random", at = { 88, 42 } },
  },

  walls   = { { type = "Tube", at = { 92, 41 } }, { type = "Wall", at = { 80, 30 } } },
  regions = { your_base = { 30, 50, 45, 62 }, spawn_point = { 93, 39 } },
  markers = { drop_zone = { type = "Circle", at = { 50, 50 } } },
}
```

Every section is optional. Keys the core doesn't know are ignored, so a file can carry notes for tools. Since the
file is Lua it may compute its tables (a loop laying out a row of beacons, say), but it runs before the game is
set up, so it should build data and not call the game.

### Header

| Key | Used by |
|---|---|
| `name` | The tools (OP2LuaEditor, the converters). The mission list shows the DLL's `LevelDesc`. |
| `map` | The tools, and a check: the core logs a warning when it differs (ignoring case) from the DLL's `MapName`. The DLL's map is the one that loads. |
| `tech` | The tools. The game uses the DLL's `TechtreeName`. |
| `type` | The tools (names in the table above). The game uses the DLL's `DescBlock`. |
| `max_tech` | The tools. The game uses the DLL's `DescBlock`. |
| `players_count` | The tools. The game uses the DLL's `DescBlock`. |

OP2LuaEditor's Mission Properties keeps the header and the DLL in step (name, map, type, players, max tech).

### `players`

A table keyed by player number, **1-based** (`[1]` is the first player). Each entry:

| Key | Default | Meaning |
|---|---|---|
| `colony` | `"Eden"` | `"Eden"` or `"Plymouth"`; anything else is Eden. |
| `human` | `true` | `false` makes a computer player. |
| `color` | the game's | `Blue`, `Red`, `Green`, `Yellow`, `Cyan`, `Magenta`, `Black`, `White`; an unknown name is Blue. Left out, the colour stays as the game set it. |
| `resources` | | See below. |
| `center_view` | | `{ x, y }`: the tile the view starts on, for the player at this computer. |
| `allies` | | A list of player numbers (1-based) this player is mutually allied with. |

`resources`, all optional:

| Key | Default | Meaning |
|---|---|---|
| `common_ore`, `rare_ore` | 0 | Stored ore. The game caps it at the colony's storage at the colony's first update, so ore beyond what the starting structures hold is lost (see API.md, `player.ore`). |
| `food` | 0 | Stored food. |
| `kids`, `workers`, `scientists` | 0 | Population. |
| `solar_satellites` | | Solar Power Satellites in orbit (applied when above 0). |
| `edward_satellites` | | EDWARD Satellites in orbit (applied when above 0): with one up every mining beacon counts as surveyed for the player. |
| `tech_level` | | Gives every topic whose tech ID is at most 1000 times this, and the free topics after them (applied when above 0). |
| `completed_research` | | A list of tech IDs (from the tech tree file) marked researched. |

Some files carry `bot` on a player or `morale` in `resources`; the core reads neither (the script can hold morale
with `game.morale_steady`).

When `resources` is present every number in it is set, so a left-out `common_ore` means 0 ore, not the game's
starting amount.

**Multiplayer missions leave `players` out.** The lobby has already chosen each player's colony, colour and
human or computer, and a `players` entry would override them. Without it `players[]` still gets every player in
the game; set starting resources from the script (API.md, Multiplayer missions).

### `units`

A list, made in order. Each entry:

| Key | Default | Meaning |
|---|---|---|
| `type` | (required) | A vehicle or structure name (table below). An unknown type is skipped with a warning in the log, and still counts for beacons' `after`. |
| `player` | 1 | The owner, 1-based. |
| `at` | | `{ x, y }`. |
| `name` | | Publishes the unit as `units["name"]` for the script. |
| `weapon` | none | The turret of a combat vehicle or Guard Post (weapon names below). An unknown name gives no weapon. On a Guard Post `"Starflare"` and `"Supernova"` make the Guard Post versions of those weapons. |
| `direction` | `"East"` | `East`, `SouthEast`, `South`, `SouthWest`, `West`, `NorthWest`, `North`, `NorthEast`; an unknown name is East. |
| `lights` | `true` | A vehicle's headlights. |
| `health` | 1.0 | The share of hit points left: `0.5` starts the unit half damaged. |
| `cargo` | | A Cargo Truck's load (cargo names below). An unknown name is ignored with a warning. |
| `amount` | 1000 | How much `cargo` the truck carries. |
| `kit` | | A ConVec's structure kit: a structure name. An unknown name is ignored with a warning. |
| `kit_topping` | | The kit's weapon, for a Guard Post kit (Starflare and Supernova as for `weapon`). |

A mine (`CommonOreMine`, `RareOreMine`) must stand on a beacon that already exists: give the beacon no `after`
(it is then made before every unit) or an `after` no later than the mine's position in the list. A mine with no
beacon under it crashes the game.

**Unit types**

- Vehicles: `CargoTruck`, `ConVec`, `Spider`, `Scorpion`, `Lynx`, `Panther`, `Tiger`, `RoboSurveyor`,
  `RoboMiner`, `GeoCon`, `Scout`, `RoboDozer`, `EvacuationTransport`, `RepairVehicle`, `Earthworker`,
  `SmallCapacityAirTransport`.
- Structures: `CommandCenter`, `StructureFactory`, `VehicleFactory`, `ArachnidFactory`, `ConsumerFactory`,
  `CommonOreMine`, `RareOreMine`, `CommonOreSmelter`, `RareOreSmelter`, `CommonStorage`, `RareStorage`,
  `Agridome`, `Residence`, `ReinforcedResidence`, `AdvancedResidence`, `Nursery`, `University`, `MedicalCenter`,
  `RecreationFacility`, `Forum`, `DIRT`, `Garage`, `RobotCommand`, `TradeCenter`, `BasicLab`, `StandardLab`,
  `AdvancedLab`, `Observatory`, `Spaceport`, `MeteorDefense`, `GORF`, `GuardPost`, `LightTower`, `Tokamak`,
  `MHDGenerator`, `SolarPowerArray`, `GeothermalPlant`, `MagmaWell`.
- Also accepted: `Tube`, `Wall`, `LavaWall`, `MicrobeWall` (better in `walls`) and `Wreckage`.

**Weapons**: `Laser`, `Microwave`, `RailGun`, `RPG`, `EMP`, `ESG`, `Stickyfoam`, `AcidCloud`, `ThorsHammer`,
`Starflare`, `Supernova`, `EnergyCannon` (the Scorpion's).

**Cargo**: `Food`, `CommonOre`, `RareOre`, `CommonMetal`, `RareMetal`, `CommonRubble`, `RareRubble`,
`Spacecraft`, `Wreckage`, `GeneBank`, `Empty`; also `Ore` (CommonOre), `Metal` (CommonMetal) and `Rubble`
(CommonRubble).

### `beacons`

A list. Each entry:

| Key | Default | Meaning |
|---|---|---|
| `type` | `"MiningBeacon"` | `MiningBeacon`, `MagmaVent` or `Fumarole`. |
| `ore` | `"Random"` | A mining beacon's ore: `Common`, `Rare` or `Random`. |
| `yield` | `"Random"` | `Bar3`, `Bar2`, `Bar1` or `Random`. |
| `variant` | `"Random"` | `High`, `Mid`, `Low` or `Random` (also `Variant1`, `Variant2`, `Variant3`). |
| `at` | | `{ x, y }`. |
| `name` | | Publishes the beacon as `units["name"]`. |
| `after` | 0 | When to make it: 0 (or left out) before the first unit; `n` right after the n-th entry of `units`; a number past the last entry after all of them. |

`after` exists so a converted mission makes its objects in the original's order, which gives every unit the same
object id as in the original. Unknown `yield` and `variant` names are Random.

### `walls`

A list of `{ type =, at = { x, y } }`, one tile each. `type` is `Wall` (the default), `LavaWall`, `MicrobeWall`
or `Tube`.

### `regions`

A table of name to point (`{ x, y }`) or rectangle (`{ x1, y1, x2, y2 }`). Each becomes `regions["name"]` in the
script, a Region in status-bar coordinates (API.md, Region).

### `markers`

A table of name to `{ type =, at = { x, y } }`. `type` is `Circle` (the default), `DNA` or `Beaker`; the marker is
drawn on the map. Each becomes `markers["name"]` = `{ x =, y = }` in the script, holding the **game's own tile**
(0-based, with the hidden margin), not the status-bar coordinate.

### What the core makes, in order

When the mission starts (the game's `InitProc`), before `on_init`:

1. `players`: each listed player's colony, human or computer, colour, resources, view and allies.
2. Beacons with no `after` (or `after = 0`).
3. `units`, in list order; after the n-th entry, the beacons with `after = n`. Then the beacons whose `after` is
   past the last entry.
4. `walls`.
5. `regions`, then `markers`.
6. The script's globals `players`, `units`, `regions` and `markers` are set.

These globals don't exist while the script file itself is being run (at load); use them from `on_init` on.

## `<Mission>.lua`

An ordinary Lua chunk run once when the mission loads, after the placement file has been read. It defines
globals; the core then looks up these callbacks by name, any of which may be left out:

| Callback | When |
|---|---|
| `on_init()` | Once at the start, after the placement is applied. Return `false` (or `nil`) to abort the mission; returning nothing carries on. |
| `on_tick()` | Every game tick, after the scheduled events of that tick. |
| `on_chat(chat)` | A chat message. |
| `on_create_unit(unit)`, `on_destroy_unit(unit)` | A unit made or destroyed (OPU 1.4.0 and later). |
| `on_damage_unit(target, source, damage)` | A unit damaged (OPU 1.4.2 and later). |
| `on_load()`, `on_unload()`, `on_end(result)` | The game loads the mission, unloads it, or ends it (`result`: how; API.md). |
| `on_save()`, `on_load_save()` | The game saves, or loads a saved game. |

Everything a script can call is in [API.md](API.md).

**The Lua environment**: Lua 5.4 with the `base`, `string`, `table` and `math` libraries; no `io`, `os`,
`package` or `require`, no `dofile`, `loadfile` or `load`, and no `math.random` or `math.randomseed` (use
`game.rand`, which every player in a multiplayer game draws the same). `print` writes to the mission's log,
`OPU\logs\OP2Lua-<base>.log`. A fresh Lua state is made
for each mission, so nothing carries over from the last one. The placement file and the script share that state.

**Saved games**: the mission gives the game no data to save, so a saved game holds the units and the map but
not the script's variables or pending timers.
