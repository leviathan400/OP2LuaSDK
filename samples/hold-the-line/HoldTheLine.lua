-- Example 1: "Hold the Line"  (mission.lua)
--
-- A colony-defense mission: survive the enemy assault for 15 minutes,
-- or destroy their Command Center to win early.
--
-- This file is ONLY the logic. The map, players, your base, and the enemy
-- base are placed in the editor and live in placement.lua next to this file.
-- Objects placed there get a Name - you refer to them here by that name.
--
-- placement.lua defines:
--   region "spawn_point"  - where enemy waves appear
--   region "your_base"    - the area you must protect
--   unit   "enemy_cc"     - the enemy Command Center (destroy it to win early)
--   players 1 (you) and 2 (the AI attacker)

local wave = 0

-- Called once when the mission starts. Return false to abort with an error.
function on_init()
  game.message("Hold the line for 15 minutes - or destroy their base!")

  -- Scheduling is tick-based and runs identically on every client,
  -- so all of this is automatically multiplayer-safe.
  every(marks(2 * 60), send_wave)            -- a wave every 2 minutes
  after(marks(15 * 60), function()           -- survive 15 min -> you win
    mission.win(players[1])
  end)

  -- `when` polls a condition each tick and fires once, the first time it's true.
  when(function() return not players[1]:owns_any("CommandCenter") end, function()
    game.message("Your colony is lost...")
    mission.lose(players[1])
  end)

  return true
end

-- Just a normal Lua function - write as many helpers as you like.
function send_wave()
  wave = wave + 1
  local size = 2 + wave                        -- waves grow over time

  -- game.rand(n) -> 0..n-1 is the ONLY random source. It's synced across all
  -- players, so every client spawns the exact same wave. (Never math.random.)
  local kinds = { "Lynx", "Tiger" }
  local kind  = kinds[ game.rand(#kinds) + 1 ]

  local attackers = game.create_unit{
    type   = kind,
    player = players[2],
    at     = regions["spawn_point"],
    count  = size,
    weapon = "Microwave",
  }
  for _, tank in ipairs(attackers) do
    tank:attack_move(regions["your_base"])
  end

  game.message(("Wave %d: %d %ss incoming!"):format(wave, size, kind))
end

-- Event callback: fires whenever any unit is destroyed.
function on_destroy_unit(unit)
  if unit == units["enemy_cc"] then            -- early win
    game.message("Enemy base destroyed - victory!")
    mission.win(players[1])
  end
end
