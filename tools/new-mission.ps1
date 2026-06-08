<#
.SYNOPSIS
  Scaffold a new OP2Lua mission: a named mission DLL + skeleton .lua scripts.

.DESCRIPTION
  Clones the prebuilt mission stub (bin\LuaMission.dll), byte-patches its menu name and map, and
  writes starter MissionName.lua + MissionName.placement.lua next to it. No compiler required.
  (This is the manual stand-in for the future OP2MissionEditor .opm -> Lua converter.)

.EXAMPLE
  .\new-mission.ps1 -Name "My First Mission"
.EXAMPLE
  .\new-mission.ps1 -Name "Red Dawn" -Map "sgame01.map" -OutDir "C:\missions"
#>
param(
  [Parameter(Mandatory = $true)] [string] $Name,
  [string] $Map = "eden01.map",
  [string] $OutDir
)

$ErrorActionPreference = "Stop"
$sdkRoot = Split-Path $PSScriptRoot                 # tools\ -> SDK root
$stub    = Join-Path $sdkRoot "bin\LuaMission.dll"
if (-not (Test-Path $stub)) { throw "Stub not found: $stub  (run from inside the SDK folder)" }
if (-not $OutDir) { $OutDir = Join-Path $sdkRoot "out" }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# Base name = the menu name with non-alphanumerics removed. The DLL base name decides which .lua
# files it loads (MyMission.dll -> MyMission.lua + MyMission.placement.lua).
$base = ($Name -replace '[^A-Za-z0-9]', '')
if (-not $base) { throw "Name '$Name' has no letters/digits to form a file name." }

# --- Patch a fixed char[1024] export string inside the cloned DLL ------------------------------
function Set-DllString([byte[]] $bytes, [string] $old, [string] $new) {
  $latin1 = [Text.Encoding]::GetEncoding(28591)
  $idx = $latin1.GetString($bytes).IndexOf($old)
  if ($idx -lt 0) { throw "Template string '$old' not found in stub DLL." }
  $nb = [Text.Encoding]::ASCII.GetBytes($new)
  if ($nb.Length -ge 1024) { throw "'$new' is too long." }
  $clear = [Math]::Max($old.Length, $nb.Length + 1)   # wipe old contents, leave a null terminator
  for ($k = 0; $k -lt $clear; $k++)        { $bytes[$idx + $k] = 0 }
  for ($k = 0; $k -lt $nb.Length; $k++)    { $bytes[$idx + $k] = $nb[$k] }
}

# Overwrite a UTF-16 string in the version resource (FileDescription) with the mission name, so the
# mission DLL's Windows Properties show "<Mission Name>". Length-preserving (zero-fills the field).
function Set-DllWideString([byte[]] $bytes, [string] $placeholder, [string] $value) {
  $u16 = [Text.Encoding]::Unicode
  $needle = $u16.GetBytes($placeholder)
  $idx = -1
  for ($i = 0; $i -le $bytes.Length - $needle.Length; $i++) {
    $hit = $true
    for ($j = 0; $j -lt $needle.Length; $j++) { if ($bytes[$i + $j] -ne $needle[$j]) { $hit = $false; break } }
    if ($hit) { $idx = $i; break }
  }
  if ($idx -lt 0) { throw "FileDescription placeholder not found in stub DLL (resource missing?)." }
  if ($value.Length -gt $placeholder.Length) { throw "'$value' is too long for the description field." }
  $field = ($placeholder.Length + 1) * 2     # bytes, includes the UTF-16 null
  for ($k = 0; $k -lt $field; $k++) { $bytes[$idx + $k] = 0 }
  $vb = $u16.GetBytes($value)
  for ($k = 0; $k -lt $vb.Length; $k++) { $bytes[$idx + $k] = $vb[$k] }
}

$descPlaceholder = "OP2Lua mission name placeholder - set by the new-mission tool"  # must match LuaMission.rc

$dll = [IO.File]::ReadAllBytes($stub)
Set-DllString     $dll "OP2Lua mission (unpatched template)" $Name   # menu name (OP2 mission list)
Set-DllString     $dll "eden01.map" $Map                             # map file
Set-DllWideString $dll $descPlaceholder $Name                        # Windows file-description = name
[IO.File]::WriteAllBytes((Join-Path $OutDir "$base.dll"), $dll)

# --- placement.lua skeleton -------------------------------------------------------------------
$placement = @"
-- $base.placement.lua  -  $Name  -  starting layout.
-- Coordinates are the ones shown on the in-game status bar (hover a tile to read them).
return {
  name = "$Name", map = "$Map", tech = "MULTITEK.TXT", type = "Colony",
  max_tech = 12, players_count = 2,

  players = {
    [1] = { colony = "Eden", human = true, color = "Blue",
            resources = { common_ore = 3000, food = 3000, kids = 8, workers = 12, scientists = 6, tech_level = 9 },
            center_view = { 30, 55 } },
    [2] = { colony = "Plymouth", human = false, color = "Red",
            resources = { common_ore = 4000, food = 4000, kids = 15, workers = 20, scientists = 10, tech_level = 12 } },
  },

  units = {
    -- Your starting force (player 1).
    { type = "Lynx",          player = 1, at = { 30, 54 }, weapon = "Laser" },
    { type = "Lynx",          player = 1, at = { 31, 54 }, weapon = "RPG" },
    { type = "CommandCenter", player = 1, at = { 28, 56 } },
    { type = "Tokamak",       player = 1, at = { 31, 57 } },

    -- The enemy you fight (player 2). A powered Guard Post will fire at you.
    { type = "CommandCenter", player = 2, at = { 58, 44 } },
    { type = "Tokamak",       player = 2, at = { 60, 44 } },
    { type = "GuardPost",     player = 2, at = { 58, 46 }, weapon = "RPG" },
  },

  beacons = {}, walls = {},
  regions = { enemy_base = { 54, 40, 64, 48 } },   -- a rectangle: { x1, y1, x2, y2 }
  markers = {},
}
"@

# --- mission.lua skeleton ---------------------------------------------------------------------
$mission = @"
-- $base.lua  -  $Name  -  mission logic.
-- See docs/API.md for the full API. Edit freely; this is your mission.

function on_init()
  game.message("${Name}: destroy the enemy Command Center!")
  game.sound("NewMissionObjective")
  game.morale_steady()   -- keep morale stable so it's about the fight, not colony micro

  -- WIN: the enemy has no Command Center left.
  when(function() return not players[2]:owns_any("CommandCenter") end, function()
    game.message("Enemy base destroyed - mission accomplished!")
    game.sound("StructureDestroyed")
    mission.win()
  end)

  -- LOSE: your colony's Command Center is gone.
  when(function() return not players[1]:owns_any("CommandCenter") end, function()
    game.message("Your Command Center is destroyed. Mission failed.")
    mission.lose()
  end)

  -- Example (uncomment to try): reinforcements at mark 10.
  -- at_mark(10, function()
  --   game.message("Reinforcements have arrived!")
  --   game.create_unit{ type = "Lynx", player = players[1], at = { 30, 54 }, count = 3, weapon = "Laser" }
  -- end)
end
"@

Set-Content -Path (Join-Path $OutDir "$base.placement.lua") -Value $placement -Encoding ASCII
Set-Content -Path (Join-Path $OutDir "$base.lua")           -Value $mission   -Encoding ASCII

Write-Host ""
Write-Host "Created mission '$Name' in $OutDir :" -ForegroundColor Green
Write-Host "  $base.dll              (menu name '$Name', map '$Map')"
Write-Host "  $base.lua              (edit your logic here)"
Write-Host "  $base.placement.lua    (edit your layout here)"
Write-Host ""
Write-Host "Next: copy all three files into your Outpost 2  OPU\maps  folder, then launch the game."
Write-Host "See ..\INSTALL.md for paths and ..\docs\GETTING-STARTED.md for the walkthrough."
