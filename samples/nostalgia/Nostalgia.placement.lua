-- Nostalgia.placement.lua  -  Nostalgia (Lua)
-- One human colony vs. one *idle* computer colony on the 4-corner "Nostalgia" layout.
-- Ported from the classic C++ mission data (NostalgiaBaseData.h / NostalgiaMain.cpp).
--
-- COORDINATES: the C++ source uses OP2 *engine* coordinates. OP2Lua placement coords are author /
-- status-bar coords, which GameMap::At() converts back to engine via engine_x = author_x - 1 + 32
-- (32 = map left-padding) and engine_y = author_y - 1. To render where the original mission placed
-- things, we undo that here: author = (engineX - 31, engineY + 1). Verified in-game - without it,
-- everything sat 31 tiles too far right. Author X can go <= 0; that's fine, the +32 padding inside
-- GameMap::At pulls it back into valid engine space. OFF_X/OFF_Y are the one knob (e.g. a map with
-- different padding).
local OFF_X, OFF_Y = 31, -1
local function coord(x, y) return { x - OFF_X, y - OFF_Y } end   -- engine coords -> author coords

-- ---------------------------------------------------------------------------------------------
-- Base layouts (offsets relative to a base centre, in tile units) - from NostalgiaBaseData.h.
-- We use two diagonally-opposite corners: set 1 (top-left, +offsets) and set 4 (bottom-right,
-- -offsets). Centres are the "Tokmak Corner" base offsets base0/base3.
-- ---------------------------------------------------------------------------------------------

-- { offX, offY, type }
local buildingSet1 = {
  {  2, 10, "CommandCenter"    },
  {  8, 10, "StructureFactory" },
  {  8,  6, "CommonOreSmelter" },
  {  2,  2, "Tokamak"          },
  {  2, 16, "StandardLab"      },
  {  2, 13, "Agridome"         },
}
local buildingSet4 = {
  { -2,  -9, "CommandCenter"    },
  { -7, -10, "StructureFactory" },
  {-12,  -2, "CommonOreSmelter" },
  { -1,  -1, "Tokamak"          },
  { -2, -15, "StandardLab"      },
  { -2, -12, "Agridome"         },
}

-- { offX, offY, type, direction, weapon? }
local unitSet1 = {
  {  5, 13, "ConVec",       "East"      },
  {  7, 13, "ConVec",       "East"      },
  {  9, 13, "ConVec",       "East"      },
  {  5, 19, "CargoTruck",   "East"      },
  {  7, 19, "CargoTruck",   "East"      },
  {  9, 19, "CargoTruck",   "East"      },
  { 16,  3, "RoboSurveyor", "SouthWest" },
  { 18,  1, "RoboMiner",    "SouthWest" },
  {  8, 16, "Earthworker",  "East"      },
  { 21, 19, "GuardPost",    "East", "Microwave" },
}
local unitSet4 = {
  { -9,  -7, "ConVec",       "West"      },
  { -7,  -7, "ConVec",       "West"      },
  { -5,  -7, "ConVec",       "West"      },
  { -9, -19, "CargoTruck",   "West"      },
  { -7, -19, "CargoTruck",   "West"      },
  { -5, -19, "CargoTruck",   "West"      },
  {-10,  -5, "RoboSurveyor", "SouthEast" },
  {-12,  -7, "RoboMiner",    "SouthEast" },
  { -8, -16, "Earthworker",  "West"      },
  {-22, -18, "GuardPost",    "East", "Microwave" },
}

-- Tube segments (offsets {x1,y1,x2,y2}) - from tubeSet1 / tubeSet4. Expanded tile-by-tile
-- into the walls list below (OP2Lua places tubes one tile at a time, like CreateTube).
local tubeSet1 = {
  {  5, 10,  5, 10 },   -- Structure Factory to CC
  { 11, 10, 19, 10 },   -- SF to corner
  { 20, 10, 20, 19 },   -- corner to GP
}
local tubeSet4 = {
  {-10, -10, -20, -10 }, -- SF to corner
  {-21, -10, -21, -18 }, -- corner to GP
  {-12,  -4, -12,  -9 }, -- tube to SM
  { -4, -10,  -4, -10 }, -- CC to SF
}

-- ---------------------------------------------------------------------------------------------
-- Build the units / walls tables programmatically from the layouts above.
-- ---------------------------------------------------------------------------------------------

local units = {}
local walls = {}

local function addBase(cx, cy, player, ccName, buildings, vehicles)
  for _, b in ipairs(buildings) do
    local u = { type = b[3], player = player, at = coord(cx + b[1], cy + b[2]) }
    if b[3] == "CommandCenter" and ccName then u.name = ccName end
    units[#units + 1] = u
  end
  for _, v in ipairs(vehicles) do
    local u = { type = v[3], player = player, at = coord(cx + v[1], cy + v[2]), direction = v[4] }
    if v[5] then u.weapon = v[5] end
    units[#units + 1] = u
  end
end

local function addTubes(cx, cy, segments)
  for _, s in ipairs(segments) do
    local x1, y1, x2, y2 = s[1], s[2], s[3], s[4]
    local dx = (x2 > x1) and 1 or (x2 < x1) and -1 or 0
    local dy = (y2 > y1) and 1 or (y2 < y1) and -1 or 0
    local x, y = x1, y1
    while true do
      walls[#walls + 1] = { type = "Tube", at = coord(cx + x, cy + y) }
      if x == x2 and y == y2 then break end
      x = x + dx; y = y + dy
    end
  end
end

-- Player 1 (human) base: top-left corner, base0 = (33, 1).
addBase(33, 1, 1, "human_cc", buildingSet1, unitSet1)
addTubes(33, 1, tubeSet1)

-- Player 2 (idle AI) base: bottom-right corner, base3 = (158, 125).
addBase(158, 125, 2, "ai_cc", buildingSet4, unitSet4)
addTubes(158, 125, tubeSet4)

-- ---------------------------------------------------------------------------------------------
-- Mining beacons (extraSet) - absolute coords. ore/yield decoded from the C++ fields:
-- oreType 0 = Common, 1 = Rare;  barYield 0->Bar3, 1->Bar2, 2->Bar1 (matches the C++ comments).
-- ---------------------------------------------------------------------------------------------

-- { ex, ey, ore, yield }
local mines = {
  -- Base common mines (one per corner)
  {  15,   8, "Common", "Bar2" },
  { 120,   8, "Common", "Bar2" },
  {  15, 124, "Common", "Bar2" },
  { 120, 124, "Common", "Bar2", "ai_beacon" },   -- nearest beacon to the AI base; named for the AI brain
  -- Outside-base common mines
  {  14,  38, "Common", "Bar2" },
  {  91,  13, "Common", "Bar2" },
  { 114,  92, "Common", "Bar2" },
  {  37, 114, "Common", "Bar2" },
  -- Side common mines
  {  65,   6, "Common", "Bar2" },
  { 122,  65, "Common", "Bar2" },
  {  63, 122, "Common", "Bar2" },
  {   7,  64, "Common", "Bar2" },
  -- Middle common mines
  {  51,  57, "Common", "Bar2" },
  {  72,  51, "Common", "Bar2" },
  {  77,  72, "Common", "Bar2" },
  {  56,  78, "Common", "Bar2" },
  -- Outside-base rare mines (1 bar)
  {  37,  15, "Rare", "Bar1" },
  { 114,  37, "Rare", "Bar1" },
  {  91, 114, "Rare", "Bar1" },
  {  14,  92, "Rare", "Bar1" },
  -- Side rare mines (2 bar)
  {  76,   6, "Rare", "Bar2" },
  { 122,  76, "Rare", "Bar2" },
  {  52, 122, "Rare", "Bar2" },
  {   7,  53, "Rare", "Bar2" },
  -- Middle rare mines (3 bar)
  {  64,  56, "Rare", "Bar3" },
  {  64,  73, "Rare", "Bar3" },
}

-- NOTE: beacons use the C++ numbers RAW (no coord() conversion). Verified in-game: the structures
-- need the engine->author shift to line up, but the mining beacons sit correctly at the unshifted
-- coordinates. (CreateMine evidently lands at a different reference than CreateUnit/CreateBase.)
local beacons = {}
for _, m in ipairs(mines) do
  local b = { type = "MiningBeacon", ore = m[3], yield = m[4], at = { m[1], m[2] } }
  if m[5] then b.name = m[5] end   -- optional named handle (e.g. "ai_beacon"), referenced by the script
  beacons[#beacons + 1] = b
end

-- ---------------------------------------------------------------------------------------------
-- The placement table.
-- ---------------------------------------------------------------------------------------------

-- Standard OPU multiplayer starting research (from NostalgiaMain.cpp InitProc).
local startResearch = { 3401, 3305, 3304, 3303 }

return {
  name = "Nostalgia (Lua)", map = "opu_02.map", tech = "MULTITEK.TXT", type = "Colony",
  max_tech = 12, players_count = 2,

  players = {
    -- Player 1: you (human Eden colony, top-left).
    [1] = {
      colony = "Eden", human = true, color = "Blue",
      resources = { common_ore = 3000, rare_ore = 1500, food = 5000,
                    kids = 12, workers = 18, scientists = 10,
                    completed_research = startResearch },
      center_view = coord(35, 11),   -- on the human Command Center
    },
    -- Player 2: the idle AI (computer Plymouth colony, bottom-right). human=false -> GoAI():
    -- a computer player that does nothing on its own (OP2 has no real AI). The scaffold for a
    -- future scripted opponent - see docs/AI-DESIGN.md.
    [2] = {
      colony = "Plymouth", human = false, color = "Red",
      resources = { common_ore = 3000, rare_ore = 1500, food = 5000,
                    kids = 12, workers = 18, scientists = 10,
                    completed_research = startResearch },
    },
  },

  units   = units,
  walls   = walls,
  beacons = beacons,

  regions = {
    human_base = coord(35, 11),    -- point: human CC
    ai_base    = coord(156, 116),  -- point: AI CC
  },
}
