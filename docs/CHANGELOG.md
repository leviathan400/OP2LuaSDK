# Changelog

All notable changes to the OP2Lua SDK. Engine internals are in the OP2Lua changelog.

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
