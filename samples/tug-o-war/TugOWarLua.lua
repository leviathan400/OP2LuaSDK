-- TugOWarLua.lua  -  2 Player, LastOne, 'Tug-O-War' map, remade in OP2Lua.
--
-- A remake of the stock multiplayer mission ml2_31.dll from what it does, not from its code: its game
-- calls were recorded under different lobby choices (op2dll calls --start, op2-rs's op2-missionhost)
-- and compared. When the lobby allows disasters, one comes every 120 to 240 marks: an earthquake,
-- electrical storm, vortex or meteor, anywhere on the map.
--
-- The mission log (OPU\logs\OP2Lua-TugOWarLua.log) records the lobby's settings, who got which start,
-- and each disaster.
--
-- Coordinates are the in-game status-bar ones (map file tile + 1).

-- The two starts. The game gives the north start to a random player and the south start to the other.
local STARTS = {
  { -- north
    command = { 19, 14 },
    structures = {
      { "CommonOreSmelter", { 15, 14 } }, { "CommandCenter", { 19, 14 } }, { "Agridome", { 14, 18 } },
      { "StructureFactory", { 20, 17 } }, { "StandardLab", { 14, 21 } }, { "Tokamak", { 25, 14 } },
    },
    -- Laser Guard Posts at both ends of the tube line, far from the base itself.
    guard_posts = { { 13, 49 }, { 9, 52 }, { 49, 14 }, { 52, 9 } },
    vehicles_at = { 22, 22 },
  },
  { -- south
    command = { 46, 50 },
    structures = {
      { "CommonOreSmelter", { 51, 51 } }, { "CommandCenter", { 46, 50 } }, { "Agridome", { 50, 48 } },
      { "StructureFactory", { 42, 50 } }, { "StandardLab", { 46, 47 } }, { "Tokamak", { 50, 40 } },
    },
    guard_posts = { { 53, 23 }, { 56, 23 }, { 18, 58 }, { 19, 52 } },
    vehicles_at = { 43, 41 },
  },
}

-- Every player's vehicles, whatever the lobby chose.
local VEHICLES = { "CargoTruck", "CargoTruck", "ConVec", "ConVec", "RoboSurveyor", "RoboMiner", "Earthworker" }

-- By the lobby's resource level (player.difficulty: "Easy" is high resources, "Hard" low): the
-- colonists and stores, the research done beyond 3303 (which everyone gets), and the kits in the
-- Structure Factory's bays (bay = kit).
local LEVELS = {
  Easy = {
    workers = 27, scientists = 18, kids = 22, food = 3000, ore = 6000,
    research = { 3304, 3305, 3401 },
    kits = { [1] = "VehicleFactory", [2] = "RobotCommand", [3] = "Nursery", [4] = "University",
             [5] = "Tokamak", [6] = "Residence" },
  },
  Normal = {
    workers = 24, scientists = 15, kids = 20, food = 2000, ore = 4000,
    research = { 3304, 3305 },
    kits = { [3] = "Nursery", [4] = "University", [5] = "Tokamak", [6] = "Residence" },
  },
  Hard = {
    workers = 20, scientists = 12, kids = 18, food = 1000, ore = 2000,
    research = {},
    kits = { [6] = "Residence" },
  },
}

-- Beacons whose yield is rolled each game: Bar2 or Bar1, ore and variant random.
local ROLLED_BEACONS = {
  { 6, 22 }, { 35, 6 }, { 18, 8 }, { 47, 7 }, { 57, 40 }, { 49, 58 }, { 26, 57 }, { 41, 56 },
}

-- The lobby's resource level, as the lobby names it (player.difficulty reads it as Easy/Normal/Hard).
local RESOURCE_NAMES = { Easy = "High", Normal = "Medium", Hard = "Low" }

-- The map is 64 x 64 tiles; a disaster's tiles are drawn anywhere on it.
local MAP_SIZE = 64

-- Marks between disasters, as the original: 120 to 240 (2 and 4 make one every few marks, for testing).
local DISASTER_MIN, DISASTER_MAX = 120, 240

local function disaster_delay()
  return marks(DISASTER_MIN) + game.rand(marks(DISASTER_MAX - DISASTER_MIN) + 1)
end

local function level_of(player)
  return LEVELS[player.difficulty] or LEVELS.Easy
end

-- One player's base at `start`, with its factory kits, vehicles and the lobby's starting Lynx.
local function build_base(player, start)
  for _, s in ipairs(start.structures) do
    local made = game.create_unit{ type = s[1], player = player, at = s[2], exact = true }
    if s[1] == "StructureFactory" and made[1] then
      for bay, kit in pairs(level_of(player).kits) do made[1]:set_factory_cargo(bay, kit) end
    end
  end
  for _, at in ipairs(start.guard_posts) do
    game.create_unit{ type = "GuardPost", player = player, at = at, weapon = "Laser", exact = true }
  end
  player:center_view(start.command)
  for _, v in ipairs(VEHICLES) do
    game.create_unit{ type = v, player = player, at = start.vehicles_at, lights = true }
  end
  local weapon = player.is_eden and "Laser" or "Microwave"
  for _ = 1, game.initial_units() do
    game.create_unit{ type = "Lynx", player = player, at = start.vehicles_at, weapon = weapon, lights = true }
  end
end

local function set_resources(player)
  local level = level_of(player)
  player:mark_research(3303)
  player.workers, player.scientists, player.kids = level.workers, level.scientists, level.kids
  player.food, player.ore = level.food, level.ore
  for _, tech in ipairs(level.research) do player:mark_research(tech) end
end

local function random_tile()
  return { game.rand(MAP_SIZE) + 1, game.rand(MAP_SIZE) + 1 }
end

local function on_off(on) return on and "on" or "off" end

-- One disaster, chosen at random, then the next one 120 to 240 marks later.
local function disaster()
  local kind = game.rand(4)
  if kind == 0 then
    local at = random_tile()
    game.create_earthquake(at, 1)
    print(string.format("mark %d: earthquake at %d, %d", game.mark(), at[1], at[2]))
  elseif kind == 1 or kind == 2 then
    local from = random_tile()
    local to = random_tile()
    if kind == 1 then game.create_lightning(from, to, 10) else game.create_tornado(from, to, 10, false) end
    print(string.format("mark %d: %s from %d, %d to %d, %d", game.mark(),
                        kind == 1 and "electrical storm" or "vortex", from[1], from[2], to[1], to[2]))
  else
    local at = random_tile()
    game.create_meteor(at, 1)
    print(string.format("mark %d: meteor at %d, %d", game.mark(), at[1], at[2]))
  end
  after(disaster_delay(), disaster)
end

function on_init()
  print(string.format("Lobby: %d players; morale steady %s, day and night %s, disasters %s, %d initial vehicles",
                      game.num_players(), on_off(not game.uses_morale()), on_off(game.uses_day_night()),
                      on_off(game.disasters_enabled()), game.initial_units()))

  local north = game.rand(2) + 1          -- the player (1-based) who gets the north start
  for id = 1, game.num_players() do
    local p = players[id]
    print(string.format("Player %d: %s, %s, resources %s, %s start", id, p.is_eden and "Eden" or "Plymouth",
                        p.is_human and "human" or "computer", RESOURCE_NAMES[p.difficulty] or p.difficulty,
                        id == north and "north" or "south"))
  end
  build_base(players[north], STARTS[1])
  if players[3 - north] then build_base(players[3 - north], STARTS[2]) end   -- a 1-player test game has no south

  for _, b in ipairs(ROLLED_BEACONS) do
    game.create_beacon{ at = b, ore = "Random", yield = (game.rand(2) == 0) and "Bar2" or "Bar1" }
  end

  for id = 1, game.num_players() do set_resources(players[id]) end

  game.set_daylight_everywhere(not game.uses_day_night())
  if game.uses_morale() then game.free_morale() else game.morale_steady("Good") end

  mission.last_one_standing("Eliminate your opponents.")

  if game.disasters_enabled() then
    local first = disaster_delay()
    after(first, disaster)
    print(string.format("First disaster at mark %d", first // 100))
  end
  return true
end
