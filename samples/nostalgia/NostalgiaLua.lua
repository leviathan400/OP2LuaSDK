-- NostalgiaLua.lua  -  4P, LoS, 'Nostalgia', remade in OP2Lua.
--
-- A remake of the multiplayer map ml4_43.dll (Leviathan's C++ mission, OPU/maps/Nostalgia) from what it
-- does: its game calls were recorded under different lobby choices (op2dll calls --start) and compared.
--
-- A simple map: a base in each corner of opu_02.map, given out at random, and Last One Standing. Every
-- player starts the same whatever the lobby's resource level or initial vehicles; only Day and Night
-- and Morale Steady come from the lobby. No disasters.
--
-- The mission log (OPU\logs\OP2Lua-NostalgiaLua.log) records the lobby's settings and who got which
-- corner. Coordinates are the in-game status-bar ones (map file tile + 1).

-- Each corner's base: structures, vehicles (type, tile, facing), a Microwave Guard Post, its tubes and
-- where the camera starts.
local CORNERS = {
  NW = { -- north-west
    view = { 2, 2 },
    structures = {
      { "CommandCenter", { 4, 12 } }, { "StructureFactory", { 10, 12 } }, { "CommonOreSmelter", { 10, 8 } },
      { "Tokamak", { 4, 4 } }, { "StandardLab", { 4, 18 } }, { "Agridome", { 4, 15 } },
    },
    vehicles = {
      { "ConVec", { 7, 15 }, "East" }, { "ConVec", { 9, 15 }, "East" }, { "ConVec", { 11, 15 }, "East" },
      { "CargoTruck", { 7, 21 }, "East" }, { "CargoTruck", { 9, 21 }, "East" }, { "CargoTruck", { 11, 21 }, "East" },
      { "RoboSurveyor", { 18, 5 }, "SouthWest" }, { "RoboMiner", { 20, 3 }, "SouthWest" }, { "Earthworker", { 10, 18 }, "East" },
    },
    guard_post = { 23, 21 },
    tubes = {
      { 7, 12 }, { 13, 12 }, { 14, 12 }, { 15, 12 }, { 16, 12 }, { 17, 12 }, { 18, 12 }, { 19, 12 },
      { 20, 12 }, { 21, 12 }, { 22, 12 }, { 22, 13 }, { 22, 14 }, { 22, 15 }, { 22, 16 }, { 22, 17 },
      { 22, 18 }, { 22, 19 }, { 22, 20 }, { 22, 21 },
    },
  },
  NE = { -- north-east
    view = { 127, 2 },
    structures = {
      { "CommandCenter", { 125, 12 } }, { "StructureFactory", { 120, 12 } }, { "CommonOreSmelter", { 115, 8 } },
      { "Tokamak", { 126, 4 } }, { "StandardLab", { 125, 18 } }, { "Agridome", { 125, 15 } },
    },
    vehicles = {
      { "ConVec", { 122, 15 }, "West" }, { "ConVec", { 120, 15 }, "West" }, { "ConVec", { 118, 15 }, "West" },
      { "CargoTruck", { 122, 21 }, "West" }, { "CargoTruck", { 120, 21 }, "West" }, { "CargoTruck", { 118, 21 }, "West" },
      { "RoboSurveyor", { 117, 5 }, "SouthEast" }, { "RoboMiner", { 115, 3 }, "SouthEast" }, { "Earthworker", { 119, 18 }, "West" },
    },
    guard_post = { 107, 22 },
    tubes = {
      { 115, 11 }, { 115, 12 }, { 115, 13 }, { 115, 14 }, { 115, 15 }, { 115, 16 }, { 115, 17 }, { 115, 18 },
      { 115, 19 }, { 115, 20 }, { 107, 21 }, { 108, 21 }, { 109, 21 }, { 110, 21 }, { 111, 21 }, { 112, 21 },
      { 113, 21 }, { 114, 21 }, { 115, 21 }, { 116, 12 }, { 117, 12 }, { 123, 12 },
    },
  },
  SW = { -- south-west
    view = { 2, 126 },
    structures = {
      { "CommandCenter", { 4, 117 } }, { "StructureFactory", { 10, 116 } }, { "CommonOreSmelter", { 10, 124 } },
      { "Tokamak", { 4, 125 } }, { "StandardLab", { 4, 111 } }, { "Agridome", { 4, 114 } },
    },
    vehicles = {
      { "ConVec", { 11, 119 }, "East" }, { "ConVec", { 9, 119 }, "East" }, { "ConVec", { 7, 119 }, "East" },
      { "CargoTruck", { 11, 107 }, "East" }, { "CargoTruck", { 9, 107 }, "East" }, { "CargoTruck", { 7, 107 }, "East" },
      { "RoboSurveyor", { 18, 121 }, "SouthWest" }, { "RoboMiner", { 20, 119 }, "SouthWest" }, { "Earthworker", { 10, 110 }, "East" },
    },
    guard_post = { 22, 105 },
    tubes = {
      { 13, 116 }, { 14, 116 }, { 15, 116 }, { 16, 116 }, { 17, 116 }, { 17, 106 }, { 17, 107 }, { 17, 108 },
      { 17, 109 }, { 17, 110 }, { 17, 111 }, { 17, 112 }, { 17, 113 }, { 17, 114 }, { 17, 115 }, { 18, 106 },
      { 19, 106 }, { 20, 106 }, { 21, 106 }, { 22, 106 }, { 7, 117 }, { 10, 119 }, { 10, 120 }, { 10, 121 },
      { 10, 122 },
    },
  },
  SE = { -- south-east
    view = { 127, 126 },
    structures = {
      { "CommandCenter", { 125, 117 } }, { "StructureFactory", { 120, 116 } }, { "CommonOreSmelter", { 115, 124 } },
      { "Tokamak", { 126, 125 } }, { "StandardLab", { 125, 111 } }, { "Agridome", { 125, 114 } },
    },
    vehicles = {
      { "ConVec", { 118, 119 }, "West" }, { "ConVec", { 120, 119 }, "West" }, { "ConVec", { 122, 119 }, "West" },
      { "CargoTruck", { 118, 107 }, "West" }, { "CargoTruck", { 120, 107 }, "West" }, { "CargoTruck", { 122, 107 }, "West" },
      { "RoboSurveyor", { 117, 121 }, "SouthEast" }, { "RoboMiner", { 115, 119 }, "SouthEast" }, { "Earthworker", { 119, 110 }, "West" },
    },
    guard_post = { 105, 108 },
    tubes = {
      { 107, 116 }, { 108, 116 }, { 109, 116 }, { 110, 116 }, { 111, 116 }, { 112, 116 }, { 113, 116 }, { 114, 116 },
      { 115, 116 }, { 116, 116 }, { 117, 116 }, { 106, 116 }, { 106, 108 }, { 106, 109 }, { 106, 110 }, { 106, 111 },
      { 106, 112 }, { 106, 113 }, { 106, 114 }, { 106, 115 }, { 115, 122 }, { 115, 117 }, { 115, 118 }, { 115, 119 },
      { 115, 120 }, { 115, 121 }, { 123, 116 },
    },
  },
}

-- The game rolls one of four orders; with 3 or 4 players, player n gets the order's nth corner. With 2,
-- player 1 gets the order's first corner and player 2 the corner diagonally opposite it.
local OPPOSITE = { NW = "SE", SE = "NW", NE = "SW", SW = "NE" }
local ORDERS = {
  { "NW", "NE", "SW", "SE" },
  { "NE", "SW", "SE", "NW" },
  { "SW", "SE", "NW", "NE" },
  { "SE", "NW", "NE", "SW" },
}

-- Every player's start, whatever the lobby's resource level.
local START = { ore = 6000, food = 3000, workers = 30, scientists = 18, kids = 22 }
local RESEARCH = { 3401, 3305, 3304, 3303 }
local KITS = { "Tokamak", "Nursery", "University", "VehicleFactory", "RobotCommand", "Residence" }  -- bays 1-6

local function on_off(on) return on and "on" or "off" end

local function build_base(player, c)
  player.ore, player.food = START.ore, START.food
  player.workers, player.scientists, player.kids = START.workers, START.scientists, START.kids
  for _, s in ipairs(c.structures) do
    local made = game.create_unit{ type = s[1], player = player, at = s[2], exact = true }
    if s[1] == "StructureFactory" and made[1] then
      for bay, kit in ipairs(KITS) do made[1]:set_factory_cargo(bay, kit) end
    end
  end
  for _, t in ipairs(c.tubes) do game.create_tube(t) end
  for _, v in ipairs(c.vehicles) do
    game.create_unit{ type = v[1], player = player, at = v[2], direction = v[3], lights = true, exact = true }
  end
  game.create_unit{ type = "GuardPost", player = player, at = c.guard_post, weapon = "Microwave", exact = true }
  player:center_view(c.view)
  for _, tech in ipairs(RESEARCH) do player:mark_research(tech) end
end

function on_init()
  local order = ORDERS[game.rand(4) + 1]
  if game.num_players() == 2 then order = { order[1], OPPOSITE[order[1]] } end
  print(string.format("Lobby: %d players; morale steady %s, day and night %s",
                      game.num_players(), on_off(not game.uses_morale()), on_off(game.uses_day_night())))
  for id = 1, game.num_players() do
    local p = players[id]
    print(string.format("Player %d: %s, %s, %s corner", id, p.is_eden and "Eden" or "Plymouth",
                        p.is_human and "human" or "computer", order[id]))
    build_base(p, CORNERS[order[id]])
  end

  game.morale_steady("Good")
  if game.uses_morale() then game.free_morale() end
  game.set_daylight_everywhere(not game.uses_day_night())
  game.set_daylight_moves(false)
  game.set_initial_light_level(-32)

  mission.last_one_standing("Eliminate your opponents.")
  return true
end
