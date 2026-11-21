# Changelog

All notable changes to the OP2Lua SDK. Engine internals are in the OP2Lua changelog.

## [Unreleased]

## [0.8.6] - 2026-11-21

### Changed

- A `move`, `attack_move` or `attack` to a unit made this tick goes out at once, as a mission DLL's `CreateUnit`
  then `DoMove` does. Through 0.8.5 such an order was held about 25 ticks, so reinforcements set off late; a
  mission that makes a unit and orders it in the same tick now sees it leave right away.
- `bin/OP2LuaCore.dll` is OP2Lua **0.8.6**; `tools/OP2LuaEditor.exe` is OP2LuaEditor **0.8.6** (build 0031).
- API.md: orders to a new unit go out at once.

## [0.8.5] - 2026-11-21

### Fixed

- `game.morale_steady()` and `game.free_morale()` with no player (every player) did nothing in 0.8.4: the player
  check took "every player" for a refused player. Missions that lock every player's morale (the tutorials, several
  campaign missions on Easy, colony games such as Hold the Line) left it free.

### Changed

- `bin/OP2LuaCore.dll` is OP2Lua **0.8.5**; `tools/OP2LuaEditor.exe` is OP2LuaEditor **0.8.5** (build 0030).
- API.md: `game.uses_morale()` reads the lobby's Morale Steady option; a mission's `game.morale_steady` doesn't
  change it.

## [0.8.4] - 2026-11-20

### Changed

- `bin/OP2LuaCore.dll` is OP2Lua **0.8.4**; `tools/OP2LuaEditor.exe` is OP2LuaEditor **0.8.4** (build 0029), which
  draws the two tube tiles the game lays beside each structure with tube connections (east of it and south of it) and
  the dozed ring around every structure, power plants and mines included.
- A fault inside a game call a script makes no longer closes the game: it comes back as a Lua error with the script's
  file and line, is logged in the mission log, and the mission carries on. `pcall` catches it like any error.
- Functions check their arguments before calling the game and refuse a bad one with a warning: player numbers
  (`create_unit`, `morale_steady`, `free_morale`, the EMP missile calls), tiles off the map (`set_tile`,
  `initial_set_tile`, `set_cell_type`), wall types (`create_wall`), and `transfer_cargo`'s bay, factory and docked
  vehicle.

## [0.8.3] - 2026-11-19

### Added

- `campaign.save` / `campaign.load` / `campaign.delete`: data a campaign mission passes to the next, in a
  `.carry` file beside the mission DLL (data only, never run as code). Single player: in multiplayer each machine
  reads its own file.

### Changed

- `bin/OP2LuaCore.dll` is OP2Lua **0.8.3**; `tools/OP2LuaEditor.exe` is OP2LuaEditor **0.8.3** (build 0028; the version
  only).
- `unit:factory_cargo(bay)` also returns the bay's weapon or cargo.

## [0.8.2] - 2026-11-19

### Changed

- `bin/OP2LuaCore.dll` is OP2Lua **0.8.2**; `tools/OP2LuaEditor.exe` is OP2LuaEditor **0.8.2** (build 0027; the version
  only).

### Added

- `OPU\logs\OP2Lua-<dll>-result.json` records how a mission ended (won, lost, aborted, ...), for launchers;
  `on_end(result)` gets the same.

## [0.8.1] - 2026-11-18

### Changed

- `bin/OP2LuaCore.dll` is OP2Lua **0.8.1**; `tools/OP2LuaEditor.exe` is OP2LuaEditor **0.8.1** (build 0026), whose
  New Mission names a Colony mission's DLL `c<Name>.dll`; `tools/op2lua-newmission.exe` does too, and writes the lobby
  skeleton for a multiplayer `--type`.
- `move` / `attack` / `attack_move` go out at once, as in a mission DLL; only a unit made this tick or the last
  waits until it can take the order.

### Added

- `game.units_closest`, `game.force_robot_command`, `game.clear_cheated`, `player:set_launched`.
- `game.play_wav(file)`: a WAV shipped with the mission; `game.message(text, false)`: a message with no sound.

### Fixed

- Area arguments take a `{ x =, y = }` point and a raw tile; `markers[name]` is in status-bar coordinates;
  `math.random`, `dofile`, `loadfile` and `load` are gone from the sandbox; empty slots read `"None"`.
- `tools/new-mission.ps1` names the DLL `c<Name>.dll`, so the mission is listed under Colony Games.
- docs: API.md checked call by call against the code, with a *Names* section; INSTALL, GETTING-STARTED, the README
  and the samples README brought up to date.

## [0.8.0] - 2026-11-18

### Changed

- `bin/OP2LuaCore.dll` is OP2Lua **0.8.0**; `tools/OP2LuaEditor.exe` is OP2LuaEditor **0.8.0** (build 0025).

### Added

- `game.morale_steady(level, player)` locks one player's morale; `unit_stat`, `set_unit_stat` and `set_required_tech`
  take a raw MapID number as well as a name.
- `game.set_music(songs, repeat_from)`, `game.player(n)`, `player:unit_stat` / `set_unit_stat`, `game.set_required_tech`, `game.set_tech_cost`,
  `player:unmark_research`, `unit.rotation`, `unit.is_stickyfoamed`, `unit.dirt_prevention`, `unit.double_fire_rate`, `unit.eden` (docs/API.md).
- `player.edward_satellites` and `player.solar_satellites` (read and set), placement `edward_satellites`: with an
  EDWARD Satellite every beacon counts as surveyed for the player.
- `hackaray.*` (docs/API.md), opt-in: with a `hackaray.load()` line a mission can switch on Hackaray.dll's nuke
  patch and set the end-of-game videos.
- `unit.lights`, `unit:set_offensive(on)` and `unit:set_emp(ticks)` (OP2LuaCore; see API.md).

## [0.7.9] - 2026-11-17

### Changed

- `bin/OP2LuaCore.dll` is OP2Lua **0.7.9**; `tools/OP2LuaEditor.exe` is OP2LuaEditor **0.7.9** (build 0025), which
  takes a campaign mission's type in Mission Properties and plays a sound when a map has loaded.

### Added

- `docs/FILE-FORMAT.md`: the mission files - every `placement.lua` key, the mission DLL's settings, how the files are
  found.

### Fixed

- Placement takes `at = { x =, y = }` and the game's own tile, `{ x =, y =, raw = true }`, as script calls do.
- The Hold the Line sample's placement comment said its coordinates were the game's own; they are status-bar ones.
- `group:first_of_type(type)` without a weapon found nothing.

## [0.7.6] - 2026-11-17

### Changed

- `bin/OP2LuaCore.dll` is OP2Lua **0.7.6**; `tools/OP2LuaEditor.exe` is OP2LuaEditor **0.7.6** (build 0024), which
  shows the open mission's `.lua` in the status bar.

### Added

- `game.version()`: the running OP2LuaCore's version and build time, e.g. `"0.7.6"`, `"2026-11-17 12:15:06"`.
- `game.op2_version()`: the version the running Outpost 2 goes by (`"1.4.0.1"` under OPU 1.4.x) and Outpost2.exe's
  file version (`"1.2.0.7"`). For display; don't branch game logic on it in multiplayer.

### Fixed

- A Guard Post armed with `"Starflare"` or `"Supernova"` no longer crashes the game when it is drawn: it gets the Guard
  Post's own turret version of the weapon (Tutorials 13 and 14 make such Guard Posts).

## [0.7.5] - 2026-11-17 - multiplayer missions

### Changed

- `bin/OP2LuaCore.dll` is OP2Lua **0.7.5**: everything below.
- `tools/OP2LuaEditor.exe` is OP2LuaEditor **0.7.5** (build 0024): saving rewrites only what you edited in
  `placement.lua`; New Mission and Properties set the mission DLL's type and player count; beacons, walls, tubes,
  markers and dozed borders on the map; Mission > Test in OP2 (F5) copies the mission into the game and starts it
  through op2launcher; the selected tile in the status bar and side panel; the game's OP2LuaCore.dll version in
  the status bar. New Mission finds `bin/LuaMission.dll` from `tools/`.

### Fixed

- `region:center()` returns the centre in the same coordinates as `unit.x`/`unit.y`, so it goes straight to `at =`
  (it returned the game's internal ones, about 32 tiles off on a normal map).
- `unit.progress` is nil whenever `unit.producing` is.
- `game.footprint` and `game.find_build_site` return nil for a type that isn't a structure.

### Added

- `player.ore_capacity` and `player.rare_ore_capacity` (read-only): how much ore the colony can store; the game caps
  `player.ore` / `player.rare_ore` at them, so ore beyond them is lost. See [`API.md`](API.md).
- API.md: ore set by a script or a placement beyond the colony's storage is lost at the next colony update (every
  256 ticks, the first at the start); a Storage holds 5000, a smelter 10000, a Command Center none. Build storage first.
- **For computer-player scripts (read-only):** `player:cost(type [, weapon])`, `player.power`, `player.food_net`,
  `game.tech(id)`, `player:can_research(id)`, `beacon:surveyed_by(player)`, and what a unit was told to do read back:
  `unit.research_topic`, `unit.producing` / `unit.progress`, `unit.target`. They change nothing, so they are safe in
  multiplayer games. `game.footprint` reads a structure's size from its type, so it answers right on small maps.
  See [`API.md`](API.md).
- **Multiplayer missions:** `op2lua-newmission --type` (e.g. `LastOneStanding`), the lobby's settings
  (`game.initial_units()`, `game.uses_day_night()`, `game.uses_morale()`), `mission.last_one_standing()`,
  `game.create_beacon{...}`, `game.set_initial_light_level(n)` and `create_unit{..., exact = true}`.
  See "Multiplayer missions" in [`API.md`](API.md).
- **Triggers and victory conditions:** `trigger.count/resource/set/midas/one_player_left/operational/
  vehicle_count/building_count{...}` with an optional `on` function, and `mission.victory` /
  `mission.failure`: the wins of Space Race, Resource Race, Midas and Land Rush. See "trigger.*" in
  [`API.md`](API.md).
- **Time and research triggers:** `trigger.time{...}`, `trigger.research{...}` and `Trigger:destroy()`, for
  the stock multiplayer missions' disasters (each one ends the trigger that fired and makes the next).
- **`game.tile(at)` and `game.set_tile(at, index)`:** read and change a tile's graphic (its tile mapping
  index), for lava maps that swap in volcano tiles before an eruption.
- **The game's AI groups:** `ai.building_group/fight_group/mining_group(player)`, `ai.unit_block{...}` and
  `player:set_default_group(group)`: a computer player's base that the game rebuilds, mines for and guards,
  as the stock Peacekeeper and La Corrida set theirs up. See "ai.*" in [`API.md`](API.md).
- **`tug-o-war` sample:** 2-player Last One Standing, a remake of the stock `ml2_31.dll` with its lobby
  settings, random starts and disasters.
- **`unit:develop(type)`** (a Spaceport builds a rocket or its cargo, e.g. `"EMPMissile"`) and
  **`player:default_group()`** (the game's own default group), for the stock auto demos.
- **`game.initial_set_tile(at, index)` and `game.set_cell_type(at, type)`**: a setup's own map edits
  (the stock tutorials').
- **Placement beacons with `after = n`**: made once `n` of the placement's units are made, so the units
  keep the object ids of a setup that made the beacon between them. Without it, beacons come first.
- **The weapon name `"EnergyCannon"`** (the Scorpion's).
- **For the stock colony games' trigger functions:** `game.units_in_range`, `game.units_in_rect`,
  `game.rand_point`, the player's `reset_checks`/`can_build_*`/`can_accumulate_*`/`total_strength`,
  `group:set_patrol` and `ai.unit_block`'s `classification` field. See [`API.md`](API.md).
- **For their computer players:** `block:create_units(player [, lights])` (a mission's exported unit
  table, as the game makes it), `game.message_at(...)` (a message pointing at a spot) and raw
  locations, `{ x =, y =, raw = true }` (the game's own tile, as a stock mission passes one off the
  map). See [`API.md`](API.md).
- **For the campaign missions:** `trigger.escape/kit/point/rect/evac/damaged`, a number for `trigger.count`'s
  `cargo`, `unit:infect()`, `unit.occupied_bay`, `unit.is_discovered`, `unit:set_damage`, `unit:set_opp_fired_upon`,
  `player:can_do_research`, `group:set_targ_counts`, `game.create_emp_missile`, `game.wreckage()` and
  `trigger.special_target`; `game.rand(0)`
  draws as the game's GetRand does, and a point off the map isn't wrapped onto it. See [`API.md`](API.md).
- **For CES1's attack waves:** `player:buildings`, `group:take_all_units`, `unit.object_on_pad`,
  `unit:launch_at_pixel` and `game.find_emp_missile_target`. See [`API.md`](API.md).

### Changed

- **`nostalgia` sample** is now the multiplayer map it was meant to grow into: 2-4 players, Last One
  Standing, a remake of `ml4_43.dll` (OPU's Nostalgia). The old 2-player colony version is gone; its DLL
  had the `c` prefix, the new one (`NostalgiaLua.dll`) has none and lists in the multiplayer lobby.
- `bin/OP2LuaCore.dll` and `tools/op2lua-newmission.exe` rebuilt with multiplayer support.
- `game.free_morale(player)` takes a Player or a 1-based number, like the rest of the API.
- `unit.busy` is the game's own `Unit::IsBusy`: true while the unit has a command. It went false while
  a Spaceport was still building.
- `ai.unit_block` records get the classification the stock missions' tables have (`NotSet`).

## [0.7.0] - 2026-11-05

### Added

- **New API** (since 0.6.0):
  - `player.difficulty` - `"Easy"`, `"Normal"` or `"Hard"`.
  - `player:satellite_count(type)` and starship / Spaceport type names (Starship colony victory).
  - `game.disasters_enabled()` and `game.set_lava_possible(area [, on])`.
  - Placement: `kit = "<Structure>"` (and `kit_topping`) on a ConVec.
  - Logging: `log.ai(...)`, `log.mission(...)`, `log.show_ai_in_game(on)` and `log.ai_status(player)`.
    See [`LOGGING.md`](LOGGING.md).
- **New samples:** Cold Front (reference colony mission), Cataclysm, Salvage, Plymouth Cold War
  (Lua clone), AI Sandbox, Smoke Test, and the reusable `disaster-director` module.
- `LICENSE` (MIT) and `THIRD_PARTY_NOTICES.md`.

### Changed

- `bin/OP2LuaCore.dll` and `bin/LuaMission.dll` updated to 0.7.0.
- Sample mission DLLs use the colony `c` prefix (e.g. `cNostalgia.dll`) so they appear under
  Colony Games; script names are unchanged.
- Logging now writes three files (main, per-mission, AI), each line stamped with the game mark.

### Fixed

- Mines placed on beacons no longer crash on load.
- `unit:dump_cargo()` and `factory:transfer_cargo(bay)` no longer crash.
- `player:has_tech`, `player:mark_research` and `unit:research` no longer crash on an invalid tech id.

## [0.6.0] - 2026-06-07

First public release: runtime, mission stub, `new-mission` tools, API docs, Getting Started guide and
the demo missions (Hold the Line, Strike Team, The Convoy, Hold the Beacon, Seek and Destroy,
Nostalgia, Feature Test).
