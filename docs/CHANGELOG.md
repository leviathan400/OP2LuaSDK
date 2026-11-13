# Changelog

All notable changes to the OP2Lua SDK. Engine internals are in the OP2Lua changelog.

## [Unreleased] - multiplayer missions

### Added

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
