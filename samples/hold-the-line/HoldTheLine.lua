-- Example 1: "Hold the Line" 
--
-- A colony-defense mission: survive the enemy assault,
-- or destroy their Command Center to win.
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
  game.morale_steady()
  game.message("Hold the line for 80 game marks - or destroy their base!")
  
  at_mark(1, function()
    game.sound("NewMissionObjective")
  end)
  
  -- Scheduling is tick-based and runs identically on every client
  every(marks(10), send_wave)    -- a wave every 10 game marks
  after(marks(80), function()    -- survive 80 marks -> you win
    mission.win(players[1])
  end)

  -- Failure condition 1: your Command Center is destroyed.
  -- (`when` polls a condition each tick and fires once, the first time it's true.)
  when(function() return not players[1]:owns_any("CommandCenter") end, function()
    game.message("Command Center destroyed. Mission failed.")
    mission.lose(players[1])
  end)

  -- Failure condition 2: your defending force is wiped out - no combat vehicles left.
  -- (player:units() counts BUILDINGS too, so we count fighting vehicles specifically: with no
  --  Vehicle Factory, once these are gone you can't hold the line.)
  local function combatUnits()
    return players[1]:unit_count("Lynx")    + players[1]:unit_count("Tiger")
         + players[1]:unit_count("Panther") + players[1]:unit_count("Scorpion")
  end
  when(function() return combatUnits() == 0 end, function()
    game.message("Your defending force is destroyed. Mission failed.")
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
  -- Assault your base: attack_move onto a BUILDING makes them path in and destroy it (a real
  -- attack), unlike attack_move onto a region, which is just an attack-ground order on a fixed point.
  -- Go for the Command Center first, then any unit/structure you still own, so they chew through the
  -- whole colony. Only fall back to the base region if you own literally nothing.
  local function yourTarget()
    local cc  = players[1]:units("CommandCenter") ; if #cc  > 0 then return cc[1]  end
    local all = players[1]:units()                ; if #all > 0 then return all[1] end
    return nil
  end
  local tgt = yourTarget()
  for _, tank in ipairs(attackers) do
    if tgt then tank:attack_move(tgt) else tank:attack_move(regions["your_base"]) end
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
