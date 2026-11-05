# Cold Front

A single-player **Colony** mission for Outpost 2, scripted with OP2Lua. You build an Eden colony on
`on1_01.map` next to a living, scripted **Plymouth AI** — while a "dormant" volcano threatens to erupt
and drive you off your starting ground. Your way out is the **starship**: evacuate enough resources and
colonists to orbit before the colony is lost.

It's also the **reference mission** for OP2Lua's features — a full computer-player economy, a volcanic
disaster, difficulty awareness, and the [logging standard](../../docs/LOGGING.md).

Requires **OP2LuaCore 0.6.7+** and the stock map `on1_01.map`.

---

## The premise

The old volcano on the lowlands is dormant... until your scientists discover it isn't. When it erupts,
lava floods the dark "lava-rock" terrain and consumes anything on it. You can't fight the lava — you
relocate, keep your colony alive, and load the starship to escape Cold Front.

Meanwhile the red **Plymouth AI** is building and expanding its own base, sending patrols and raids your
way, and a roaming **green Plymouth** raiding party crosses the map twice.

## Players (3)

| # | Player | Role |
|---|---|---|
| 1 | Eden (you, blue) | The human colony. Build, survive the eruption, evacuate to the starship. |
| 2 | Plymouth (red, AI) | A fully scripted computer base — economy, defense, expansion, attacks. |
| 3 | Plymouth (green, AI) | No base; two scripted raiding parties that cross the map and leave. |

## Objective

Build a Spaceport and **evacuate to the starship**: 10000 Rare Metals, 10000 Common Metals, 10000 Food,
and 200 Colonists. You **lose** if you have no Command Center left. (The eruption can destroy your CC —
rebuild elsewhere before your last one falls.)

> Difficulty (Easy / Normal / Hard) from the Colony Games menu is read at start (logged), reserved for
> per-difficulty tuning.

---

## What the Plymouth AI does (the showcase)

The red AI is driven entirely by the script (a "computer" player in OP2 has no built-in brain). Over a
run it:

- **Mines & smelts** — surveys deposits, deploys mines via RoboMiner (the crash-safe AI-Sandbox flow),
  and routes cargo trucks mine → smelter. Grows to **4 smelters** and **2 deposits**.
- **Builds a colony over time** — the StructureFactory makes kits, ConVecs dock-collect and deploy them:
  residences, medical, forum, rec, labs, agridomes, guard posts, a 2nd Vehicle Factory, more tokamaks.
- **Lays a tube/wall network** with two Earthworkers.
- **Produces vehicles** — dozers, miners, cargo trucks, and Lynx (Microwave / RPG / EMP).
- **Defends & attacks** — an RPG-Lynx fighting patrol loops the base perimeter; Microwave Lynx make a
  run east and fall back; EMP Lynx reposition; late-game it builds **4 more RPG Lynx** and regroups
  forces at mark 580.
- **Maintains itself** — a ConVec repairs the Tokamaks as they degrade (they blow up untended).

## The volcano (relocation disaster)

When enabled, every Slow1 ("lava-rock") tile plus the cells under buildings are marked lava-possible, and
the volcano erupts on a timer with a warning lead-in: scientists' discovery → "volcano stirring" → a
slow glow at the vent → the violent flood. The flow consumes the lowland base — but **only the player's
side**; the AI sits on terrain the lava never reaches, so it keeps competing while you scramble.

## The green raiders

Two identical raiding parties (2 EMP + 4 Microwave Lynx) spawn off-map, cut across, and vanish at the top
edge — one early (~mark 60), one late (~mark 500).

---

## Debug / tuning toggles (top of `ColdFront.lua`)

The mission ships with development settings. Flip these to taste:

| Toggle | Shipped | Effect |
|---|---|---|
| `LAVA_ON` | `false` | The whole volcano/eruption sequence. **Set `true` for the intended mission** (the eruption is the premise). |
| `AI_TEST_DEBUG` | `true` | Gives *you* a 10000 ore / 10000 food / 50 worker head start for quick testing. **Set `false` for a fair playthrough.** |
| `DAY_NIGHT_ON` | `false` | `false` = full daylight; `true` = the moving day/night terminator. |
| `AI_EVENTS_IN_GAME` | `false` | `true` echoes the AI's `log.ai` events to the in-game comms panel (watch the AI live). |

`LAVA_SPEED` / `LAVA_WARN_MARK` / `LAVA_ERUPT_MARK` tune the eruption (see the lava block).

---

## Logs it produces

Cold Front follows the [logging standard](../../docs/LOGGING.md), so a run writes:

- `OP2Lua.log` — framework: load/end, version, map, crash summaries.
- `OP2Lua-cColdFront.log` — mission events: objectives, lava, starship progress, building completions.
- `OP2Lua-cColdFront-AI.log` — **only** the Plymouth AI's behaviour (its build/produce/mine/combat
  stream). `tail -f` this to watch just the AI.
- `OP2Lua-cColdFront-AI-status.json` — a live snapshot (overwritten each mark) of the AI's resources and
  unit counts, for an external monitor to poll.

---

## Files

| File | What |
|---|---|
| `cColdFront.dll` | the mission stub (bakes `on1_01.map`, 3 players). `c`-prefixed so it lists under Colony Games. |
| `ColdFront.lua` | all the mission logic (the AI, the volcano, the raiders, the starship victory). |
| `ColdFront.placement.lua` | the starting layout: both bases, deposits, units. |

## Install / play

Copy the three files into `Outpost2\OPU\maps\LUA\` (and make sure `bin\OP2LuaCore.dll` is in your `OPU`
folder), launch Outpost 2, and pick **Cold Front** from Colony Games. See the SDK's `INSTALL.md`.

## Status

Playable showcase. The starship victory's exact per-rocket evacuation amounts are still being calibrated
(`log.ai`/`[starship]` lines report progress); everything else — the living AI, the eruption, the
raiders, the logging — runs clean.
