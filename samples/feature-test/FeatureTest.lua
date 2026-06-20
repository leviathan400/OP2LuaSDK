-- FeatureTest.lua  -  Feature Test  -  one mission that exercises the WHOLE OP2Lua author API.
--
-- Purpose: a smoke test for the core. If this plays to a win/lose with no crash, the spawn + command
-- + scheduler + query + event surface is healthy. Every step prints to this mission's own log
-- (logs/OP2Lua-FeatureTest.log), so the log doubles as a coverage checklist.
--
-- Coverage map:
--   game.*       message, sound, rand, morale_steady / free_morale, tick / mark / marks, create_unit
--   time          marks(n) -> ticks; at_mark(m) absolute; after(marks(n)) / every(marks(n)) relative
--   scheduler    after, every (+ :cancel), at, at_mark, when
--   Unit         type/owner/cargo/cargo_amount/kit, set_cargo, move, attack_move (location/unit), attack (location/unit)
--   Player       is_eden, is_human, owns_any, unit_count, units([type])
--   Region       units(player), contains(unit), center()
--   handles      players[], units[], regions[], markers[]
--   callbacks    on_init, on_tick, on_create_unit, on_destroy_unit, on_damage_unit, on_chat
--   mission      win / lose
--
-- Orders: move() repositions without attacking; attack_move() advances aggressively (fires en route).
-- Both go through the command-packet system and are safe on fresh and established units. (move() was
-- fixed in 0.5.1 - it used to crash via a raw CmdMove call; see docs/TETHYS-DoMove-BUG.md.)
--
-- Win:  destroy the enemy Command Center ("enemy_cc").   Lose: lose your Command Center ("your_cc").

local everyHandle   -- handle for an every() timer we cancel after a few fires

function on_init()
  print("=== FeatureTest on_init ===")

  -- ---- game.* : message / sound / morale / clock / rng ----
  game.message("FeatureTest: destroy the enemy Command Center to the east!", "NewMissionObjective")
  game.sound("Beep2")
  game.morale_steady("Good")
  print(string.format("clock: tick=%d mark=%d  marks(3)=%d ticks (1 mark = 100 ticks)",
                      game.tick(), game.mark(), marks(3)))
  print("rand(100) = " .. game.rand(100))

  -- ---- named handles: players[] / units[] / regions[] / markers[] ----
  print("you: is_eden=" .. tostring(players[1].is_eden) .. " is_human=" .. tostring(players[1].is_human))
  print("enemy: is_human=" .. tostring(players[2].is_human))
  print("hero is a " .. units["hero"].type .. " owned by player " .. units["hero"].owner)
  print("north marker at " .. markers["north"].x .. "," .. markers["north"].y)
  local ctr = regions["arena"]:center()
  print("arena center = " .. ctr.x .. "," .. ctr.y)

  -- ---- Unit: Cargo Truck set/read round-trip ----
  units["truck"]:set_cargo("CommonMetal", 500)
  print("truck cargo = " .. units["truck"].cargo .. " x" .. units["truck"].cargo_amount)

  -- ---- Unit: ConVec kit read-back (kit was set in placement via the 'kit' field) ----
  print("convec kit = " .. units["convec"].kit)   -- expect "Agridome"

  -- ---- Player queries ----
  print("you own a CommandCenter? " .. tostring(players[1]:owns_any("CommandCenter")))
  print("your Lynx count = " .. players[1]:unit_count("Lynx"))
  print("your unit total = " .. #players[1]:units())

  -- ---- after(): one-shot relative timer ----
  -- (a) move() the pre-placed hero to the rally point - repositions without seeking targets.
  --     (move() is fixed in 0.5.1: it now uses the command-packet path; see docs/TETHYS-DoMove-BUG.md.)
  after(marks(2), function()
    units["hero"]:move(regions["rally"])
    print("after(2 marks): hero move() to rally")
  end)
  -- (b) YOUR reinforcements: spawn + attack_move (the safe DoAttack path for fresh units).
  after(marks(3), function()
    print("after(3 marks): spawning your reinforcements")
    game.message("Reinforcements have arrived!")
    local lynx = game.create_unit{ type = "Lynx", player = players[1], at = regions["rally"],
                                   count = 3, weapon = "Laser", direction = "East" }
    for _, u in ipairs(lynx) do u:attack_move(regions["arena"]) end   -- advance on the enemy base
  end)
  -- (c) hero attack(unit): order the (old) hero to attack the enemy CC directly.
  after(marks(5), function()
    units["hero"]:attack(units["enemy_cc"])
    print("after(5 marks): hero attack() the enemy CC")
  end)
  -- (d) enemy raiders: spawn + attack(location) = attack-ground (siege) on your rally. Fresh-unit safe.
  after(marks(8), function()
    local raiders = game.create_unit{ type = "Lynx", player = players[2], at = markers["north"],
                                      count = 2, weapon = "Laser" }
    for _, r in ipairs(raiders) do r:attack(regions["rally"]) end
    print("after(8 marks): enemy raiders attack-ground the rally")
  end)
  -- (e) release the morale lock late on, to exercise free_morale.
  after(marks(12), function() game.free_morale() ; print("after(12 marks): free_morale()") end)

  -- ---- at_mark(): absolute timer -> ENEMY spawns + commands fresh AI units (the regression's path) ----
  at_mark(2, function()
    print("at_mark(2): enemy scrambles a patrol")
    local patrol = game.create_unit{ type = "Lynx", player = players[2], at = regions["arena"],
                                     count = 3, weapon = "RPG" }
    for _, e in ipairs(patrol) do e:attack_move(markers["north"]) end   -- attack_move to a marker
  end)

  -- ---- at(): absolute tick timer ----
  at(game.tick() + marks(6), function()
    game.message("Halfway report logged.")
    print("at(): halfway status")
  end)

  -- ---- every(): repeating timer, cancelled via its handle after 3 fires ----
  local fires = 0
  everyHandle = every(marks(4), function()
    fires = fires + 1
    print(string.format("every #%d: you=%d unit(s), enemy=%d unit(s)",
                        fires, #players[1]:units(), #players[2]:units()))
    if fires >= 3 and everyHandle then everyHandle:cancel() ; print("every: cancelled") end
  end)

  -- ---- when(): region trip-wire -> enemy reacts when YOU enter trip_zone (attack_move a unit = hunt) ----
  when(function() return #regions["trip_zone"]:units(players[1]) > 0 end, function()
    print("when: player entered trip_zone -> enemy hunts your hero")
    game.message("We've been spotted!", "EnemyUnitSighted")
    for _, e in ipairs(players[2]:units("Lynx")) do e:attack_move(units["hero"]) end
    print("hero in trip_zone? " .. tostring(regions["trip_zone"]:contains(units["hero"])))
  end)

  -- ---- mission win / lose ----
  when(function() return not players[2]:owns_any("CommandCenter") end, function()
    print("WIN: enemy CC destroyed")
    game.message("Enemy Command Center destroyed - you win!")
    mission.win()
  end)
  when(function() return not players[1]:owns_any("CommandCenter") end, function()
    print("LOSE: your CC destroyed")
    game.message("Your Command Center is gone - you lose.")
    mission.lose()
  end)

  print("=== on_init complete ===")
  return true
end

-- on_tick: keep it light - the scheduler does the timed work. A heartbeat proves the callback fires.
function on_tick()
  if game.tick() % 1000 == 0 then print("on_tick heartbeat @ tick " .. game.tick()) end
end

-- ---- unit event callbacks ----
function on_create_unit(unit)  print("on_create_unit: "  .. unit.type .. " (player " .. unit.owner .. ")") end
function on_destroy_unit(unit) print("on_destroy_unit: " .. unit.type .. " (player " .. unit.owner .. ")") end
function on_damage_unit(unit)  end   -- fires constantly in combat; defined to prove it routes, kept quiet

-- ---- chat callback (chat.text read/write, chat.player) ----
function on_chat(chat)
  print("on_chat from player " .. tostring(chat.player) .. ": " .. tostring(chat.text))
end
