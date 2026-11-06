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
- **`tug-o-war` sample:** 2-player Last One Standing, a remake of the stock `ml2_31.dll` with its lobby
  settings, random starts and disasters.

### Changed

- **`nostalgia` sample** is now the multiplayer map it was meant to grow into: 2-4 players, Last One
  Standing, a remake of `ml4_43.dll` (OPU's Nostalgia). The old 2-player colony version is gone; its DLL
  had the `c` prefix, the new one (`NostalgiaLua.dll`) has none and lists in the multiplayer lobby.
- `bin/OP2LuaCore.dll` and `tools/op2lua-newmission.exe` rebuilt with multiplayer support.
- `game.free_morale(player)` takes a Player or a 1-based number, like the rest of the API.

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
