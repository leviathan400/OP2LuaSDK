# Getting Started - your first Outpost 2 mission in Lua

This walks you from nothing to a playable mission in about 15 minutes. You only ever edit text.

## 0. Install the runtime (once)

Copy `bin/OP2LuaCore.dll` into your Outpost 2 `OPU` folder (see [`../INSTALL.md`](../INSTALL.md)).
Every mission shares this one file.

## 1. Scaffold a mission

From the SDK folder, run the scaffolder. Cross-platform console tool:

```
tools/op2lua-newmission "My First Mission"
```

Or, on Windows, the PowerShell script (does the same thing):

```powershell
powershell -ExecutionPolicy Bypass -File tools\new-mission.ps1 -Name "My First Mission"
```

That creates three files (in `out/` by default):

```
cMyFirstMission.dll             <- the mission OP2 lists (named "My First Mission")
MyFirstMission.lua              <- the logic  (you edit this)
MyFirstMission.placement.lua    <- the layout (you edit this)
```

The leading `c` on the DLL files it under Colony Games; the scripts keep the plain name. OP2LuaEditor's
File > New Mission makes the same three files, straight into the game's `OPU\maps\LUA\`.

The `.dll` is just a tiny pre-made loader - you never compile it. It finds and runs the two `.lua`
files sitting next to it.

## 2. Understand the two files

A mission is **nouns + verbs**:

- **`MyFirstMission.placement.lua`** = the starting state. A `return { ... }` table: players, their
  resources, and the units/structures on the map at the start. Pure data
  ([`FILE-FORMAT.md`](FILE-FORMAT.md) has every key).
- **`MyFirstMission.lua`** = what happens. You define `on_init()` and set up timers, waves, and win/lose
  rules inside it.

## 3. Place some units

Open `MyFirstMission.placement.lua`. Units look like this:

```lua
units = {
  -- Your force (player 1). Coordinates are the ones on the in-game status bar.
  { type = "Lynx",         player = 1, at = { 30, 54 }, weapon = "Laser" },
  { type = "CommandCenter", player = 1, at = { 28, 56 } },
  { type = "Tokamak",       player = 1, at = { 31, 57 } },

  -- The enemy (player 2).
  { type = "CommandCenter", player = 2, at = { 60, 44 } },
  { type = "GuardPost",     player = 2, at = { 60, 46 }, weapon = "RPG" },
},
```

**Coordinates are what you see in-game.** Launch OP2, hover a tile, read the status bar - that's the
number you type in `at = { x, y }`. No math, no offsets.

> Tip: to find good coordinates, load any sample mission and move the mouse around the map.

### Place visually instead (recommended for bigger bases)

Typing coordinates by hand is fine for a few units, but for a real base it's faster to **place
visually**, then convert:

1. **[OP2MissionEditor](https://github.com/leviathan400/OP2MissionEditor)** - load a map and drag
   units, structures, beacons, and regions into place, then save an **`.opm`** mission file.
2. **[OP2OpmTools](https://github.com/leviathan400/OP2OpmTools)** - convert that `.opm` into a
   mission (Export Lua writes all three files).

So the full layout workflow is: **place in OP2MissionEditor → save `.opm` → convert with OP2OpmTools
→ play.** You still write the logic in the mission's `.lua` by hand (next step). OP2LuaEditor (in
`tools/`) edits a mission's layout over its map directly.

## 4. Script the mission

Open `MyFirstMission.lua`. The scaffold already gives you a working win/lose. Here's the shape:

```lua
function on_init()
  game.message("Destroy the enemy Command Center!")
  game.sound("NewMissionObjective")
  game.morale_steady()          -- keep morale stable so it's about the fight

  -- WIN when the enemy has no Command Center.
  when(function() return not players[2]:owns_any("CommandCenter") end, function()
    game.message("Enemy base destroyed - you win!")
    mission.win()
  end)

  -- LOSE when your force is gone.
  when(function() return not players[1]:owns_any("CommandCenter") end, function()
    game.message("Your colony is destroyed.")
    mission.lose()
  end)
end
```

Want attack waves? Add a timer:

```lua
  -- An enemy wave every 120 marks (~2 min), growing each time. Game time is measured in MARKS
  -- (1 mark = 100 ticks; the "Current Mark" shown in-game) - use marks(n) / at_mark(m).
  local wave = 0
  every(marks(120), function()
    wave = wave + 1
    game.message("Wave " .. wave .. " incoming!")
    game.sound("WeAreUnderAttack")
    local enemies = game.create_unit{ type = "Lynx", player = players[2],
                                      at = { 60, 46 }, count = 2 + wave, weapon = "Microwave" }
    for _, e in ipairs(enemies) do e:attack_move(players[1]:units("CommandCenter")[1]) end
  end)
```

The full list of calls - scheduling, `game.*`, `unit:*`, `player:*`, `region:*` - is in
[`API.md`](API.md). Skim it once.

## 5. Install and play

Copy the three files into `OPU\maps\LUA\` (see [`../INSTALL.md`](../INSTALL.md)), launch Outpost 2,
and start a New Colony Game. "My First Mission" is in the list.

> A mission appears under **Colony Games** because its `.dll` filename starts with a lowercase `c`
> (`cMyFirstMission.dll`). If you rename the files, keep the `c` on the DLL. See
> [`../INSTALL.md`](../INSTALL.md), *Installing your own mission*.

## 6. Debug with the log

While building, lean on the log. Add `print(...)` anywhere:

```lua
print("wave " .. wave .. " spawned at tick " .. game.tick())
```

It shows up in `OPU\logs\OP2Lua-cMyFirstMission.log` - your mission's own log (named after the DLL). If anything errors, the
log names the file and line. **Always check the log first** when something doesn't behave.

## 7. Learn from the samples

The missions in `samples/` are commented - each demonstrates a different style:

| Sample | Teaches |
|---|---|
| `hold-the-line` | escalating `every(...)` waves, `morale_steady` |
| `strike-team` | `region:units`, timed `at_mark` reinforcements, ownership win |
| `the-convoy` | escort logic, `region:contains`, cargo trucks, reactive enemies |
| `hold-the-beacon` | holding a region over time, a progress counter |
| `seek-and-destroy` | `player:unit_count`, multi-target progress |
| `cold-front` | a full scripted-AI colony, a volcanic-eruption disaster, difficulty, the starship victory, the logging standard (has its own `README.md`) |
| `cataclysm` | every disaster type on a fixed timeline, on `eden01.map` (`disaster-director/` schedules them at random) |
| `tug-o-war`, `nostalgia` | multiplayer: the lobby's settings, Last One Standing (each has its own `README.md`) |

[`../samples/README.md`](../samples/README.md) lists every sample. Copy one, rename it, and tweak. That's the
fastest way to learn.

## Common gotchas (Outpost 2 quirks)

- **"Destroy X" objectives: poll ownership**, don't rely on a destroy event for buildings:
  `when(function() return not players[2]:owns_any("CommandCenter") end, mission.win)`.
- **The computer player has no AI brain.** In a scripted mission the enemy only does what your
  script tells it - spawn and command its units yourself.
- **Use the status-bar coordinates** for placement (type what you see).
- **Use the scheduler, not real time;** use `game.rand`, not `math.random` - this keeps your
  mission multiplayer-safe.

Have fun. The whole point is that a mission is just a couple of readable Lua files.
