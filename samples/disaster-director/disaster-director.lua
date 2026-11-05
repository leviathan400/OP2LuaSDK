-- disaster-director.lua  -  a random / weighted disaster scheduler for OP2Lua missions.
--
-- Recreates the gist of Sirbomber's DisasterCreator (random disaster type by weight, a minimum gap
-- between events, and targeting near a player's base) in pure Lua, on top of OP2Lua's disaster API.
-- No new bindings beyond what OP2Lua 0.6.5 already ships.
--
-- USAGE: copy install_disaster_director(...) into your mission .lua and call it once from on_init():
--
--   install_disaster_director{
--     every = 50,          -- check cadence in marks (default 50)
--     min_gap = 150,       -- minimum marks between disasters (default 100)
--     chance = 0.5,        -- probability a given check fires a disaster, 0..1 (default 0.5)
--     target_player = 1,   -- whose base disasters aim near (default 1 = the human)
--     start_mark = 100,    -- don't start before this mark (default 0)
--     kinds = {            -- weighted disaster pool (omit for the default mix)
--       { kind = "meteor",     weight = 3 },
--       { kind = "earthquake", weight = 2 },
--       { kind = "lightning",  weight = 2 },
--       { kind = "tornado",    weight = 2 },
--       -- { kind = "eruption", weight = 1 },   -- needs lava-possible terrain (see set_lava_possible)
--       -- { kind = "blight",   weight = 1 },
--     },
--     force = false,       -- true = run even if the player turned disasters OFF in the menu
--   }
--
-- It honours game.disasters_enabled() unless force=true, and uses game.rand (the synced RNG), so it is
-- multiplayer-safe.
--
-- NOTE: Colony Games have NO disasters toggle (only Difficulty), and game.disasters_enabled() returns
-- FALSE there - so by default this gate blocks. Pass force=true to run the director in a colony mission.
-- The gate (without force) is for multiplayer / skirmish, where the host's disasters choice is real.

function install_disaster_director(opts)
  opts = opts or {}
  if (not opts.force) and (game.disasters_enabled() == false) then
    print("[disasters] disabled in game settings - director not started (pass force=true to override)")
    return
  end

  local everyMarks   = opts.every or 50
  local minGap       = opts.min_gap or 100
  local chancePct    = math.floor((opts.chance or 0.5) * 100)
  local targetPlayer = opts.target_player or 1
  local startMark    = opts.start_mark or 0
  local kinds = opts.kinds or {
    { kind = "meteor",     weight = 3 },
    { kind = "earthquake", weight = 2 },
    { kind = "lightning",  weight = 2 },
    { kind = "tornado",    weight = 2 },
  }

  local totalW = 0
  for _, k in ipairs(kinds) do totalW = totalW + (k.weight or 1) end

  -- Aim near the target player's Command Center (else any building, else a random map tile),
  -- scattered a few tiles so it isn't always dead-centre.
  local function pickTarget()
    local p = players[targetPlayer]
    local b = p:units("CommandCenter")[1] or p:units()[1]
    local ms = game.map_size()
    if b and b.alive then
      local jx, jy = game.rand(13) - 6, game.rand(13) - 6   -- -6..+6
      local x = math.max(1, math.min(ms.w, b.x + jx))
      local y = math.max(1, math.min(ms.h, b.y + jy))
      return { x, y }
    end
    return { game.rand(ms.w) + 1, game.rand(ms.h) + 1 }
  end

  local function pickKind()
    local r, acc = game.rand(totalW), 0
    for _, k in ipairs(kinds) do
      acc = acc + (k.weight or 1)
      if r < acc then return k.kind end
    end
    return kinds[1].kind
  end

  local lastFired = -minGap
  every(marks(everyMarks), function()
    if game.mark() < startMark then return end
    if game.mark() - lastFired < minGap then return end
    if game.rand(100) >= chancePct then return end

    local at   = pickTarget()
    local kind = pickKind()
    local to   = { math.min(at[1] + 8, game.map_size().w), at[2] }   -- path end for storm/vortex

    if kind == "meteor" then
      game.create_meteor(at, opts.meteor_size or 1)
    elseif kind == "earthquake" then
      game.create_earthquake(at, opts.quake_magnitude or 3)
    elseif kind == "lightning" then
      game.create_lightning(at, to, opts.storm_duration or 12)
    elseif kind == "tornado" then
      game.create_tornado(at, to, opts.vortex_duration or 12)
    elseif kind == "eruption" then
      game.create_eruption(at, opts.lava_speed or 45)
    elseif kind == "blight" then
      game.create_blight(at, opts.blight_speed or 50)
    else
      print("[disasters] unknown kind '" .. tostring(kind) .. "' (skipped)")
      return
    end

    lastFired = game.mark()
    print(string.format("[disasters] mark %d: %s at (%d,%d)", game.mark(), kind, at[1], at[2]))
  end)

  print(string.format("[disasters] director started (every %d, min gap %d, chance %d%%, target player %d)",
    everyMarks, minGap, chancePct, targetPlayer))
end

-- ---------------------------------------------------------------------------------------------------
-- Minimal example mission using the director (rename to mission.lua / <Name>.lua to run it):
--
-- function on_init()
--   game.message("Disaster Director demo - storms incoming!")
--   install_disaster_director{ every = 40, min_gap = 120, chance = 0.6, target_player = 1, start_mark = 60 }
-- end
