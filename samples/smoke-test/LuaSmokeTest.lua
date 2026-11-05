-- LuaSmokeTest.lua  -  Smoke Test  -  a FULL-API smoke test for OP2Lua.
--
-- Purpose: exercise (nearly) every author binding and report a PASS/FAIL tally - to this mission's
-- log (logs/OP2Lua-cLuaSmokeTest.log) and on-screen (game.message). Run it after any OP2LuaCore or
-- TethysAPI change: if it reports 0 failed and doesn't crash, the binding surface is healthy.
-- Complements FeatureTest (which focuses on the spawn/command/scheduler "director" surface); this one
-- covers the colony/economy/perception/engineering/disaster surface added across 0.6.x.
--
-- How the tally works:
--   check(name, cond)   - PASS if cond is truthy (used for reads + round-trips with a known answer).
--   eq(name, got, want) - PASS if got == want.
--   ok(name, fn)        - PASS if fn() runs without raising (used for action bindings whose effect is
--                         async/guarded; this catches signature/dispatch breakage after an API bump).
-- NOTE: pcall (ok) does NOT catch C++ access violations, so type-specific NON-guarded bindings
-- (research/set_factory_cargo/factory_cargo/train_scientists/load-unload-dump_cargo) are called only
-- on a real unit of that type. The SEH-guarded orders (build/dock/doze/repair/...) are safe anywhere.
--
-- The mission ends in mission.win() if everything passed, mission.lose() if anything failed - so the
-- result is visible in-game even without reading the log.

local P, F = 0, 0
local fails = {}
local function pass(n)        P = P + 1; print("[PASS] " .. n) end
local function failn(n, d)    F = F + 1; fails[#fails + 1] = n
                              print("[FAIL] " .. n .. (d and ("  -- " .. tostring(d)) or "")) end
local function check(n, cond, d) if cond then pass(n) else failn(n, d) end end
local function eq(n, got, want)  if got == want then pass(n)
                                 else failn(n, "got " .. tostring(got) .. " want " .. tostring(want)) end end
local function ok(n, fn)         local s, e = pcall(fn); if s then pass(n) else failn(n, e) end end

-- Deferred probes (verified in the summary, after a few marks).
local probe = { tick = false, created = 0, destroyed = false, damaged = false,
                s_after = false, s_at = false, s_at_mark = false, s_when = false, s_every = 0 }
local everyH

-- ============================ summary (runs at mark ~4) ============================
local function summary()
  print("=== LuaSmokeTest: deferred checks (mark " .. game.mark() .. ") ===")

  -- callbacks
  check("callback on_tick fired",          probe.tick)
  check("callback on_create_unit fired",   probe.created > 0)   -- OnCreateUnit: OPU 1.4.0+
  check("callback on_destroy_unit fired",  probe.destroyed)     -- OnDestroyUnit: OPU 1.4.0+
  -- on_damage_unit maps to OnDamageUnit, an OPU 1.4.2+ callback. On 1.4.0/1.4.1 the loader never
  -- delivers it (the binding is wired identically to create/destroy, which DO fire), so this is
  -- best-effort: PASS if it fired (1.4.2+), otherwise a NOTE - NOT counted as a failure.
  if probe.damaged then
    pass("callback on_damage_unit fired (OPU 1.4.2+)")
  else
    print("[NOTE] on_damage_unit not delivered - requires OPU mod 1.4.2+ (this game is older); not a failure")
  end

  -- scheduler
  check("scheduler after()",   probe.s_after)
  check("scheduler at()",      probe.s_at)
  check("scheduler at_mark()", probe.s_at_mark)
  check("scheduler when()",    probe.s_when)
  check("scheduler every() (>=2 fires)", probe.s_every >= 2)
  ok("scheduler every():cancel()", function() if everyH then everyH:cancel() end end)

  -- ===== tally =====
  local total = P + F
  print("================================================")
  print(string.format("LuaSmokeTest RESULT: %d/%d passed, %d failed", P, total, F))
  if F > 0 then print("FAILED: " .. table.concat(fails, ", ")) end
  print("================================================")

  game.message(string.format("Smoke Test: %d/%d passed, %d failed", P, total, F))
  if F == 0 then
    game.message("SMOKE TEST PASSED - all " .. P .. " checks OK", "Beep2")
    mission.win()
  else
    game.message("SMOKE TEST FAILED - " .. F .. " of " .. total .. " (see log)")
    game.message("Failures: " .. table.concat(fails, ", "))
    mission.lose()
  end
end

-- ============================ the synchronous battery ============================
local function run_tests()
  -- Arm the scheduler/callback probes FIRST so they're live even if a later check errors.
  after(marks(1), function() probe.s_after = true end)
  at(game.tick() + marks(1), function() probe.s_at = true end)
  at_mark(game.mark() + 1, function() probe.s_at_mark = true end)
  everyH = every(marks(1), function() probe.s_every = probe.s_every + 1 end)
  when(function() return game.mark() >= 1 end, function() probe.s_when = true end)

  -- ---- handles ----
  check("handle players[1]", players[1] ~= nil)
  check("handle players[2]", players[2] ~= nil)
  for _, n in ipairs({ "cc", "factory", "lab", "uni", "convec", "truck", "tank", "fighter1", "ew", "enemy_cc", "fighter2" }) do
    check("handle units." .. n, units[n] ~= nil)
  end
  for _, n in ipairs({ "home", "arena", "rally" }) do check("handle regions." .. n, regions[n] ~= nil) end
  check("handle markers.north", markers["north"] ~= nil)

  -- ---- game: world queries ----
  check("game.num_players >= 2", game.num_players() >= 2)
  check("game.num_humans >= 1",  game.num_humans() >= 1)
  check("game.rand(100) in range", (function() local r = game.rand(100); return r >= 0 and r < 100 end)())
  check("game.tick() number", type(game.tick()) == "number")
  check("game.mark() number", type(game.mark()) == "number")
  eq("marks(3) == 300", marks(3), 300)
  local ms = game.map_size()
  check("game.map_size()", ms and ms.w > 0 and ms.h > 0)
  local c = game.cell(10, 57)
  check("game.cell()", c and type(c.passable) == "boolean" and type(c.type) == "number")
  check("game.can_place()", type(game.can_place(30, 50)) == "boolean")
  local fp = game.footprint("Agridome")
  check("game.footprint()", fp and fp.w > 0 and fp.tw >= fp.w)
  local fpl = game.find_place(units["cc"], "Agridome")
  check("game.find_place()", fpl == nil or (type(fpl) == "table" and fpl.x ~= nil))
  local fbs = game.find_build_site("Agridome", units["cc"])
  check("game.find_build_site()", fbs == nil or (type(fbs) == "table" and fbs.x ~= nil))
  local bcn = game.beacons()
  check("game.beacons() finds >=1", #bcn >= 1)
  if bcn[1] then eq("beacon.ore", bcn[1].ore, "Common") end
  check("game.beacons('Common')", #game.beacons("Common") >= 1)

  -- ---- game: actions (call-and-log) ----
  ok("game.message",        function() game.message("LuaSmokeTest running...") end)
  ok("game.sound",          function() game.sound("Beep2") end)
  ok("game.morale_steady",  function() game.morale_steady("Good") end)
  ok("game.free_morale",    function() game.free_morale() end)
  ok("game.create_marker",  function() game.create_marker({ x = 28, y = 28 }, "Circle") end)
  ok("game.create_wall",    function() game.create_wall("Wall", { 26, 28, 28, 28 }) end)
  ok("game.create_tube",    function() game.create_tube({ 26, 30, 28, 30 }) end)
  ok("game.create_wreckage", function() game.create_wreckage({ x = 30, y = 38 }, 8000, true) end)

  -- ---- game: disasters (fired mid-map at ~{30,30}, away from both bases + the fighter combat) ----
  ok("game.disasters_enabled", function() local _ = game.disasters_enabled() end)
  ok("game.create_meteor",     function() game.create_meteor({ x = 30, y = 30 }, 2, true) end)
  ok("game.create_earthquake", function() game.create_earthquake({ x = 32, y = 30 }, 1, true) end)
  ok("game.create_eruption",   function() game.create_eruption({ x = 34, y = 30 }, 50, true) end)
  ok("game.create_lightning",  function() game.create_lightning({ x = 30, y = 32 }, { x = 33, y = 32 }, 50, true) end)
  ok("game.create_tornado",    function() game.create_tornado({ x = 30, y = 34 }, { x = 34, y = 34 }, 50, true) end)
  ok("game.create_blight",     function() game.create_blight({ x = 40, y = 40 }, -1) end)
  ok("game.unset_blight",      function() game.unset_blight({ x = 40, y = 40 }) end)

  -- ---- game: environment ----
  ok("game.set_daylight_everywhere", function() game.set_daylight_everywhere(true) end)
  ok("game.set_daylight_moves",      function() game.set_daylight_moves(true) end)
  ok("game.set_lava_speed",          function() game.set_lava_speed(50) end)
  ok("game.set_blight_speed",        function() game.set_blight_speed(20) end)
  ok("game.set_lava_possible",       function() game.set_lava_possible({ 33, 30, 35, 30 }, true) end)
  ok("game.map_sound",               function() game.map_sound("Beep2", { x = 30, y = 30 }) end)

  -- ---- mission bindings exist (called for real at the end) ----
  check("mission.win is function",  type(mission.win) == "function")
  check("mission.lose is function", type(mission.lose) == "function")

  -- ---- Unit: reads / asserts ----
  eq("cc.type",        units["cc"].type, "CommandCenter")
  check("cc.is_building",  units["cc"].is_building == true)
  check("cc.is_vehicle",   units["cc"].is_vehicle == false)
  check("cc.alive",        units["cc"].alive == true)
  check("cc.valid",        units["cc"].valid == true)
  check("cc.id number",    type(units["cc"].id) == "number")
  check("cc.type_id number", type(units["cc"].type_id) == "number")
  eq("cc.owner",       units["cc"].owner, 0)
  check("factory.is_factory", units["factory"].is_factory == true)
  eq("convec.kit",     units["convec"].kit, "Agridome")
  eq("truck.cargo",        units["truck"].cargo, "CommonMetal")
  eq("truck.cargo_amount", units["truck"].cargo_amount, 500)
  eq("tank.weapon",    units["tank"].weapon, "Microwave")
  check("tank.x number", type(units["tank"].x) == "number")
  check("tank.y number", type(units["tank"].y) == "number")
  check("tank.max_hp > 0", units["tank"].max_hp > 0)
  check("tank.hp <= max_hp", units["tank"].hp <= units["tank"].max_hp)
  check("tank.health 0..1", units["tank"].health > 0 and units["tank"].health <= 1)
  check("tank.command number", type(units["tank"].command) == "number")
  for _, p in ipairs({ "busy", "enabled", "is_offensive", "is_emped", "is_infected", "disabled",
                       "idled", "under_construction" }) do
    check("tank." .. p .. " boolean", type(units["tank"][p]) == "boolean")
  end

  -- ---- Unit: round-trips ----
  units["truck"]:set_cargo("RareMetal", 750)
  eq("set_cargo -> cargo",        units["truck"].cargo, "RareMetal")
  eq("set_cargo -> cargo_amount", units["truck"].cargo_amount, 750)
  units["tank"]:set_weapon("RPG")
  eq("set_weapon -> weapon", units["tank"].weapon, "RPG")
  units["tank"]:set_weapon("Microwave")
  units["convec"]:set_kit("Nursery")
  eq("set_kit -> kit", units["convec"].kit, "Nursery")
  units["convec"]:set_kit("Agridome")
  local hp0 = units["tank"].hp
  units["tank"]:damage(50)
  eq("damage(50) -> hp", units["tank"].hp, hp0 - 50)
  units["tank"]:heal(50)
  eq("heal(50) -> hp", units["tank"].hp, hp0)
  ok("set_lights", function() units["tank"]:set_lights(true) end)

  -- ---- Unit: orders (queued / guarded) ----
  ok("unit:move",         function() units["tank"]:move(regions["rally"]) end)
  ok("unit:attack_move",  function() units["tank"]:attack_move(units["enemy_cc"]) end)
  ok("unit:attack",       function() units["tank"]:attack(regions["arena"]) end)
  ok("unit:stop",         function() units["tank"]:stop() end)
  ok("unit:stand_ground", function() units["tank"]:stand_ground(regions["rally"]) end)
  ok("unit:guard",        function() units["tank"]:guard(units["cc"]) end)
  -- attack(unit): order fighter1 onto the adjacent enemy fighter2 to guarantee the skirmish that
  -- drives the on_damage_unit / on_destroy_unit callbacks (the two start hostile; allied only at mark 3).
  ok("unit:attack(unit)", function() units["fighter1"]:attack(units["fighter2"]) end)

  -- ---- Unit: engineering (all SEH-guarded -> safe to call on the ConVec) ----
  ok("unit:build",       function() units["convec"]:build({ x = 18, y = 60 }) end)
  ok("unit:dock",        function() units["convec"]:dock(units["factory"]) end)
  ok("unit:deploy",      function() units["convec"]:deploy({ x = 18, y = 60 }) end)
  ok("unit:survey",      function() if bcn[1] then units["convec"]:survey(bcn[1]) end end)
  ok("unit:repair",      function() units["convec"]:repair(units["cc"]) end)
  ok("unit:dismantle",   function() units["convec"]:dismantle(units["enemy_cc"]) end)  -- enemy: no-op (guarded)
  ok("unit:reprogram",   function() units["convec"]:reprogram(units["fighter2"]) end)
  ok("unit:build_wall",  function() units["ew"]:build_wall("Wall", { 18, 62, 20, 62 }) end)   -- Earthworker (correct type)
  ok("unit:remove_wall", function() units["ew"]:remove_wall({ 18, 62, 20, 62 }) end)
  ok("unit:doze",        function() units["convec"]:doze({ 18, 63, 20, 63 }) end)
  ok("unit:salvage",     function() units["convec"]:salvage(regions["arena"], units["cc"]) end)
  ok("unit:dock_at_garage", function() units["convec"]:dock_at_garage(units["factory"]) end)

  -- ---- Cargo Truck (load/unload/dump are NOT guarded -> call on the real truck) ----
  ok("unit:load_cargo",   function() units["truck"]:load_cargo() end)
  ok("unit:unload_cargo", function() units["truck"]:unload_cargo() end)
  ok("unit:dump_cargo",   function() units["truck"]:dump_cargo() end)
  ok("unit:mining_route", function() units["truck"]:mining_route(units["cc"], units["factory"]) end)

  -- ---- Factory (set_factory_cargo/factory_cargo NOT guarded -> call on the real factory) ----
  ok("unit:produce",            function() units["factory"]:produce("Lynx", "Laser") end)
  ok("unit:set_factory_cargo",  function() units["factory"]:set_factory_cargo(1, "Lynx", "Laser") end)
  check("unit:factory_cargo string", type(units["factory"]:factory_cargo(1)) == "string")
  ok("unit:transfer_cargo",     function() units["factory"]:transfer_cargo(1) end)
  ok("unit:dock_location",      function() local _ = units["factory"]:dock_location() end)
  ok("unit:unit_on_dock",       function() local _ = units["factory"]:unit_on_dock() end)
  ok("unit:idle",               function() units["factory"]:idle() end)
  ok("unit:unidle",             function() units["factory"]:unidle() end)

  -- ---- Lab / University (research/train NOT guarded -> call on the real types) ----
  ok("unit:research",         function() units["lab"]:research(3401, 1) end)   -- 3401 = a real MULTITEK topic
  ok("unit:train_scientists", function() units["uni"]:train_scientists(1) end)

  -- ---- Player: reads ----
  check("p1.is_eden",     players[1].is_eden == true)
  check("p1.is_human",    players[1].is_human == true)
  check("p1.is_plymouth", players[1].is_plymouth == false)
  check("p2.is_human",    players[2].is_human == false)
  check("p1.is_ai boolean", type(players[1].is_ai) == "boolean")
  check("p1:owns_any(CC)",      players[1]:owns_any("CommandCenter") == true)
  check("p2:owns_any(CC)",      players[2]:owns_any("CommandCenter") == true)
  check("p1:owns_any(none)",    players[1]:owns_any("GuardPost") == false)
  check("p1:unit_count(Tiger)", players[1]:unit_count("Tiger") >= 1)
  check("p1:units() > 0",       #players[1]:units() > 0)
  check("p1:units(CC) >= 1",    #players[1]:units("CommandCenter") >= 1)
  for _, p in ipairs({ "ore", "rare_ore", "food", "kids", "workers", "scientists", "population" }) do
    check("p1." .. p .. " number", type(players[1][p]) == "number")
  end
  check("p1.difficulty string", type(players[1].difficulty) == "string")
  check("p1:satellite_count number", type(players[1]:satellite_count("EDWARDSatellite")) == "number")

  -- ---- Player: round-trip writes ----
  local o0 = players[1].ore
  players[1].ore = o0 + 100
  eq("p1.ore write", players[1].ore, o0 + 100)
  players[1].ore = o0
  local f0 = players[1].food
  players[1].food = f0 + 50
  eq("p1.food write", players[1].food, f0 + 50)
  players[1].food = f0

  -- ---- Player: tech (mark_research -> has_tech round-trip) ----
  ok("p1:set_tech_level", function() players[1]:set_tech_level(12) end)
  -- Valid tech id: 3401 = "Cybernetic Teleoperation" (MULTITEK.TXT). mark_research -> has_tech round-trip.
  check("p1:has_tech(valid) boolean", type(players[1]:has_tech(3401)) == "boolean")
  players[1]:mark_research(3401)
  check("mark_research -> has_tech(valid)", players[1]:has_tech(3401) == true)
  -- Bad tech id (hardened in 0.6.11): the binding validates the id and, if invalid, logs an error +
  -- shows an in-game message instead of crashing. We exercise just ONE binding here (has_tech) so the
  -- comms panel gets a single message - mark_research / research share the identical guard
  -- (IsValidTechId + ReportBadTech), so this one check covers the bad-id mechanism for all three.
  -- 999999 is not a real tech: this must NOT crash, has_tech returns false, and one error is logged.
  check("p1:has_tech(bad) safe -> false (logs 1 error)", players[1]:has_tech(999999) == false)

  -- ---- Player: alliances / faction / view ----
  check("p1:is_ally boolean", type(players[1]:is_ally(players[2])) == "boolean")
  -- Ally the two players only AFTER combat (mark 3): allying them at tick 0 would suppress the
  -- fighter1-vs-fighter2 skirmish that provokes on_damage_unit. Tested here, tallied at the summary.
  after(marks(3), function()
    ok("p1:ally_with",          function() players[1]:ally_with(players[2]) end)
    ok("p1:mutually_ally_with", function() players[1]:mutually_ally_with(players[2]) end)
  end)
  ok("p2:go_human",           function() players[2]:go_human() end)
  ok("p2:go_ai",              function() players[2]:go_ai() end)
  ok("p1:center_view",        function() players[1]:center_view(units["cc"]) end)

  -- ---- Region ----
  check("region:units() > 0",          #regions["home"]:units() > 0)
  check("region:units(player) > 0",    #regions["home"]:units(players[1]) > 0)
  check("region:contains(cc)",         regions["home"]:contains(units["cc"]) == true)
  check("region:contains(enemy_cc) no", regions["home"]:contains(units["enemy_cc"]) == false)
  local ctr = regions["arena"]:center()
  check("region:center()", ctr and type(ctr.x) == "number" and type(ctr.y) == "number")

  -- ---- markers ----
  check("marker.x/.y number", type(markers["north"].x) == "number" and type(markers["north"].y) == "number")

  -- ---- lifecycle: throwaway units (kill also drives the on_destroy_unit probe) ----
  local junk = game.create_unit{ type = "Scout", player = players[1], at = regions["rally"], count = 4 }
  check("create_unit returns count", #junk == 4)
  if junk[1] then eq("created unit type", junk[1].type, "Scout") end
  ok("unit:kill",          function() if junk[1] then junk[1]:kill() end end)
  ok("unit:remove",        function() if junk[2] then junk[2]:remove() end end)
  ok("unit:self_destruct", function() if junk[3] then junk[3]:self_destruct() end end)
  ok("unit:transfer",      function() if junk[4] then junk[4]:transfer(players[2]) end end)
end

-- ============================ entry points ============================
function on_init()
  print("=== LuaSmokeTest on_init (OP2Lua full-API smoke test) ===")
  after(marks(4), summary)                 -- schedule the report FIRST, so it runs even if the battery throws
  local s, e = pcall(run_tests)
  if not s then failn("on_init battery raised", e) end
  print("=== LuaSmokeTest synchronous battery complete: " .. P .. " passed, " .. F .. " failed so far ===")
  return true
end

function on_tick()        if not probe.tick then probe.tick = true end end
function on_create_unit(u)  probe.created = probe.created + 1 end
function on_destroy_unit(u) probe.destroyed = true end
function on_damage_unit(t)  if not probe.damaged then probe.damaged = true; print("on_damage_unit fired (OPU 1.4.2+)") end end
function on_chat(chat)      print("on_chat from " .. tostring(chat.player) .. ": " .. tostring(chat.text)) end
