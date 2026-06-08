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
MyFirstMission.dll              <- the mission OP2 lists (named "My First Mission")
MyFirstMission.lua              <- the logic  (you edit this)
MyFirstMission.placement.lua    <- the layout (you edit this)
```

The `.dll` is just a tiny pre-made loader - you never compile it. It finds and runs the two `.lua`
files sitting next to it.

## 2. Understand the two files

A mission is **nouns + verbs**:

- **`placement.lua`** = the starting state. A `return { ... }` table: players, their resources, and
  the units/structures on the map at the start. Pure data.
- **`mission.lua`** = what happens. You define `on_init()` and set up timers, waves, and win/lose
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
   `placement.lua` for your mission.

So the full layout workflow is: **place in OP2MissionEditor → save `.opm` → convert with OP2OpmTools
→ drop the generated `placement.lua` next to your mission.** You still write the logic in
`mission.lua` by hand (next step).

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
[`API.md`](API.md). Skim it once; it's short.

## 5. Install and play

Copy the three files into `OPU\maps\LUA\` (see [`../INSTALL.md`](../INSTALL.md)), launch Outpost 2,
and start a New Colony Game. "My First Mission" is in the list.

> For the mission to appear under **Colony Games**, the `.dll` filename must start with a lowercase
> `c` (e.g. `cMyFirstMission.dll`). The two `.lua` files keep the plain name - the runtime strips
> the leading `c` when it looks for them. See [`../INSTALL.md`](../INSTALL.md) (Step 2).

## 6. Debug with the log

While building, lean on the log. Add `print(...)` anywhere:

```lua
print("wave " .. wave .. " spawned at tick " .. game.tick())
```

It shows up in `OPU\logs\OP2Lua-MyFirstMission.log` - your mission's own log. If anything errors, the
log names the file and line. **Always check the log first** when something doesn't behave.

## 7. Learn from the samples

The five missions in `samples/` are short and commented - each demonstrates a different style:

| Sample | Teaches |
|---|---|
| `hold-the-line` | escalating `every(...)` waves, `morale_steady` |
| `strike-team` | `region:units`, timed `at_mark` reinforcements, ownership win |
| `the-convoy` | escort logic, `region:contains`, cargo trucks, reactive enemies |
| `hold-the-beacon` | holding a region over time, a progress counter |
| `seek-and-destroy` | `player:unit_count`, multi-target progress |

Copy one, rename it, and tweak. That's the fastest way to learn.

## Common gotchas (Outpost 2 quirks)

- **"Destroy X" objectives: poll ownership**, don't rely on a destroy event for buildings:
  `when(function() return not players[2]:owns_any("CommandCenter") end, mission.win)`.
- **The computer player has no AI brain.** In a scripted mission the enemy only does what your
  script tells it - spawn and command its units yourself.
- **Use the status-bar coordinates** for placement (type what you see).
- **Use the scheduler, not real time;** use `game.rand`, not `math.random` - this keeps your
  mission multiplayer-safe.

Have fun. The whole point is that a mission is just a couple of readable Lua files.
