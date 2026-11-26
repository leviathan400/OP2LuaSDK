<#
.SYNOPSIS
  Make a new OP2Lua mission (its DLL + starter .lua scripts), or rebuild a mission's DLL from its placement.

.DESCRIPTION
  Outpost 2 reads a mission's name, map, tech tree, type, player count, maximum tech level, unit-only flag and a
  multiplayer game's AI players from its DLL before any Lua runs. This script copies the prebuilt stub
  (bin\LuaMission.dll) and writes each value at its export (LevelDesc, MapName, TechtreeName, DescBlock,
  DescBlockEx) - the same bytes as op2lua-newmission and OP2LuaEditor's Save - then writes starter
  <Base>.lua + <Base>.placement.lua, whose header holds the same values. No compiler required.

  A single-player mission's DLL is c<Base>.dll (Outpost 2 lists it under Colony Games, the core finds its scripts
  as <Base>.*); a multiplayer type's is <Base>.dll.

  -DllFrom <Base.placement.lua> builds the DLL beside an existing mission from its placement's header instead
  (name, map, tech, type, max_tech, players_count, unit_only, ai_players; a key the header lacks comes from the
  DLL already there). The old DLL is kept as .bak; a DLL that isn't an OP2Lua stub is left alone.

.EXAMPLE
  .\new-mission.ps1 -Name "My First Mission"
.EXAMPLE
  .\new-mission.ps1 -Name "Red Dawn" -Map "sgame01.map" -OutDir "C:\missions"
.EXAMPLE
  .\new-mission.ps1 -Name "Relocation" -Map Q01.MAP -Tech Q01.tek -Type 1 -MaxTech 3
.EXAMPLE
  .\new-mission.ps1 -Name "Duel" -Type LastOneStanding -Players 4 -AiPlayers 1
.EXAMPLE
  .\new-mission.ps1 -DllFrom "C:\Outpost2\OPU\maps\LUA\MyMission.placement.lua"
#>
param(
  [string] $Name,
  [string] $Map = "eden01.map",
  [string] $Tech = "MULTITEK.TXT",
  # Colony, Tutorial, AutoDemo, a campaign mission's number (1-12), or a multiplayer type: LandRush, SpaceRace,
  # ResourceRace, Midas, LastOneStanding (MultiLandRush etc. too).
  [string] $Type = "Colony",
  [int] $Players = 2,
  [int] $MaxTech = 12,
  [switch] $UnitOnly,
  [int] $AiPlayers = 0,
  [string] $OutDir,
  [string] $Stub,
  [string] $DllFrom
)

$ErrorActionPreference = "Stop"
$sdkRoot = Split-Path $PSScriptRoot                 # tools\ -> SDK root
if (-not $Stub) { $Stub = Join-Path $sdkRoot "bin\LuaMission.dll" }
if (-not (Test-Path $Stub)) { throw "Stub not found: $Stub  (run from inside the SDK folder, or pass -Stub)" }

$TextExportLen = 1024
$descPlaceholder = "OP2Lua mission name placeholder - set by the new-mission tool"  # must match LuaMission.rc

# --- mission types ----------------------------------------------------------------------------------------------
function Get-TypeValue([string] $n) {
  $n = $n.Trim()
  $num = 0
  if ([int]::TryParse($n, [ref] $num)) { if ($num -ge 1 -and $num -le 12) { return $num } else { return 0 } }
  switch ($n.ToLowerInvariant()) {
    "colony" { return -1 }
    "autodemo" { return -2 }
    "tutorial" { return -3 }
    { $_ -in "multilandrush", "landrush" } { return -4 }
    { $_ -in "multispacerace", "spacerace" } { return -5 }
    { $_ -in "multiresourcerace", "resourcerace" } { return -6 }
    { $_ -in "multimidas", "midas" } { return -7 }
    { $_ -in "multilastonestanding", "lastonestanding" } { return -8 }
  }
  return 0
}
function Get-TypeName([int] $v) {
  if ($v -ge 1 -and $v -le 12) { return "$v" }
  $names = @{ -1 = "Colony"; -2 = "AutoDemo"; -3 = "Tutorial"; -4 = "MultiLandRush"; -5 = "MultiSpaceRace";
              -6 = "MultiResourceRace"; -7 = "MultiMidas"; -8 = "MultiLastOneStanding" }
  return $names[$v]
}

# --- the DLL's exports ------------------------------------------------------------------------------------------

# A named export's file offset and how many bytes of its section's file data follow it, or $null.
function Get-ExportSpan([byte[]] $b, [string] $name) {
  try {
    $pe = [BitConverter]::ToInt32($b, 0x3C)
    if ([BitConverter]::ToUInt32($b, $pe) -ne 0x4550) { return $null }
    $nSec = [BitConverter]::ToUInt16($b, $pe + 6)
    $optSize = [BitConverter]::ToUInt16($b, $pe + 20)
    $magic = [BitConverter]::ToUInt16($b, $pe + 24)
    $dataDirs = $pe + 24 + $(if ($magic -eq 0x20B) { 112 } else { 96 })
    $sections = $pe + 24 + $optSize
    $toSpan = {
      param([long] $rva)
      for ($s = 0; $s -lt $nSec; $s++) {
        $sec = $sections + $s * 40
        $vsize = [BitConverter]::ToUInt32($b, $sec + 8); $va = [BitConverter]::ToUInt32($b, $sec + 12)
        $raw = [BitConverter]::ToUInt32($b, $sec + 16); $ptr = [BitConverter]::ToUInt32($b, $sec + 20)
        if ($rva -ge $va -and $rva -lt $va + [Math]::Max($vsize, $raw) -and $rva - $va -lt $raw) {
          $at = [long]($rva - $va + $ptr)
          return @{ At = $at; Room = [Math]::Min([long]($raw - ($rva - $va)), $b.Length - $at) }
        }
      }
      return $null
    }
    $exp = & $toSpan ([BitConverter]::ToUInt32($b, $dataDirs))
    if (-not $exp) { return $null }
    $nNames = [BitConverter]::ToUInt32($b, $exp.At + 24)
    $funcs = & $toSpan ([BitConverter]::ToUInt32($b, $exp.At + 28))
    $names = & $toSpan ([BitConverter]::ToUInt32($b, $exp.At + 32))
    $ords = & $toSpan ([BitConverter]::ToUInt32($b, $exp.At + 36))
    $want = [Text.Encoding]::ASCII.GetBytes($name)
    for ($i = 0; $i -lt $nNames; $i++) {
      $n = & $toSpan ([BitConverter]::ToUInt32($b, $names.At + 4 * $i))
      if (-not $n) { continue }
      if ($b[$n.At + $want.Length] -ne 0) { continue }
      $same = $true
      for ($k = 0; $k -lt $want.Length; $k++) { if ($b[$n.At + $k] -ne $want[$k]) { $same = $false; break } }
      if (-not $same) { continue }
      $ord = [BitConverter]::ToUInt16($b, $ords.At + 2 * $i)
      return & $toSpan ([BitConverter]::ToUInt32($b, $funcs.At + 4 * $ord))
    }
  } catch { }
  return $null
}

function Set-TextExport([byte[]] $b, [string] $name, [string] $value) {
  $s = Get-ExportSpan $b $name
  if (-not $s -or $s.Room -lt $TextExportLen) { throw "The stub DLL has no $name export (is it LuaMission.dll?)." }
  [Array]::Clear($b, $s.At, $TextExportLen)
  $v = [Text.Encoding]::ASCII.GetBytes($value)
  [Array]::Copy($v, 0, $b, $s.At, $v.Length)
}

function Set-IntExport([byte[]] $b, [string] $name, [int[]] $values) {
  $s = Get-ExportSpan $b $name
  if (-not $s -or $s.Room -lt 4 * $values.Length) { throw "The stub DLL has no $name export (is it LuaMission.dll?)." }
  for ($k = 0; $k -lt $values.Length; $k++) { [Array]::Copy([BitConverter]::GetBytes($values[$k]), 0, $b, $s.At + 4 * $k, 4) }
}

function Get-TextExport([byte[]] $b, [string] $name) {
  $s = Get-ExportSpan $b $name
  if (-not $s) { return $null }
  $e = $s.At
  $end = $s.At + [Math]::Min($s.Room, $TextExportLen)
  while ($e -lt $end -and $b[$e] -ne 0) { $e++ }
  return [Text.Encoding]::ASCII.GetString($b, $s.At, $e - $s.At)
}

function Get-IntExport([byte[]] $b, [string] $name, [int] $index) {
  $s = Get-ExportSpan $b $name
  if (-not $s -or $s.Room -lt 4 * ($index + 1)) { return $null }
  return [BitConverter]::ToInt32($b, $s.At + 4 * $index)
}

# What a mission DLL describes, or $null.
function Read-MissionDll([byte[]] $b) {
  $t = Get-IntExport $b "DescBlock" 0
  $level = Get-TextExport $b "LevelDesc"; $map = Get-TextExport $b "MapName"; $tech = Get-TextExport $b "TechtreeName"
  if ($null -eq $t -or $null -eq $level -or $null -eq $map -or $null -eq $tech) { return $null }
  $ai = Get-IntExport $b "DescBlockEx" 0
  $typeName = Get-TypeName $t
  return @{
    Name = $level; Map = $map; Tech = $tech; Type = $(if ($typeName) { $typeName } else { "Colony" })
    Players = [int](Get-IntExport $b "DescBlock" 1); MaxTech = [int](Get-IntExport $b "DescBlock" 2)
    UnitOnly = ((Get-IntExport $b "DescBlock" 3) -ne 0); AiPlayers = $(if ($null -eq $ai) { 0 } else { $ai })
  }
}

# Overwrites the version resource's FileDescription with the mission name, within its existing room.
function Set-WideString([byte[]] $b, [string] $placeholder, [string] $value) {
  $u16 = [Text.Encoding]::Unicode
  $idx = $u16.GetString($b).IndexOf($placeholder + [char]0, [StringComparison]::Ordinal)   # even offsets only: UTF-16 text is word-aligned
  if ($idx -lt 0) { return $false }
  $at = 2 * $idx
  $cap = $placeholder.Length
  $p = $at + 2 * $placeholder.Length
  while ($p + 1 -lt $b.Length -and $b[$p] -eq 0 -and $b[$p + 1] -eq 0) { $cap++; $p += 2 }
  if ($value.Length -gt $cap - 1) { return $false }
  [Array]::Clear($b, $at, $cap * 2)
  $v = $u16.GetBytes($value)
  [Array]::Copy($v, 0, $b, $at, $v.Length)
  return $true
}

# Why the properties can't go into a DLL, or $null.
function Get-Problem($p) {
  if (-not $p.Name -or -not $p.Name.Trim()) { return "the name can't be empty" }
  foreach ($v in $p.Name, $p.Map, $p.Tech) {
    if ($v -match '[^\x00-\x7F]') { return "the name, map and tech tree are stored in the DLL as plain ASCII" }
    if ($v.Length -ge $TextExportLen) { return "the name, map and tech tree must be under 1024 characters" }
  }
  if (-not $p.Map) { return "no map" }
  if (-not $p.Tech) { return "no tech tree file" }
  if ((Get-TypeValue $p.Type) -eq 0) { return "unknown type '$($p.Type)'" }
  if ($p.Players -lt 1 -or $p.Players -gt 6) { return "players must be 1-6" }
  if ($p.MaxTech -lt 0 -or $p.MaxTech -gt 12) { return "the max tech level must be 0-12" }
  if ($p.AiPlayers -lt 0 -or $p.AiPlayers -gt 5) { return "AI players must be 0-5" }
  return $null
}

# The mission DLL the properties describe: the stub with each value written at its export.
function New-MissionDll($p) {
  $why = Get-Problem $p
  if ($why) { throw "Can't make the DLL: $why." }
  $b = [IO.File]::ReadAllBytes($Stub)
  Set-TextExport $b "LevelDesc" $p.Name
  Set-TextExport $b "MapName" $p.Map
  Set-TextExport $b "TechtreeName" $p.Tech
  Set-IntExport $b "DescBlock" @((Get-TypeValue $p.Type), $p.Players, $p.MaxTech, $(if ($p.UnitOnly) { 1 } else { 0 }))
  Set-IntExport $b "DescBlockEx" @($p.AiPlayers)
  if (-not (Set-WideString $b $descPlaceholder $p.Name)) {
    Write-Host "note: the DLL's Windows file description keeps the stub's text (name too long, or no placeholder)."
  }
  return , $b
}

function Test-Multiplayer([string] $type) { $v = Get-TypeValue $type; return ($v -le -4 -and $v -ne 0) }

# --- -DllFrom: an existing mission's DLL from its placement's header ---------------------------------------------
if ($DllFrom) {
  if ($Name) { throw "-DllFrom takes no -Name (it reads the placement's)." }
  $placementPath = (Resolve-Path $DllFrom).Path
  $file = Split-Path $placementPath -Leaf
  if ($file -notmatch '(?i)^(.+)\.placement\.lua$') { throw "$file isn't a <Base>.placement.lua." }
  $base = $Matches[1]
  $dir = Split-Path $placementPath
  $text = [IO.File]::ReadAllText($placementPath)

  $target = @((Join-Path $dir "c$base.dll"), (Join-Path $dir "$base.dll")) | Where-Object { Test-Path $_ } | Select-Object -First 1
  $old = $null; $oldProps = $null
  if ($target) { $old = [IO.File]::ReadAllBytes($target); $oldProps = Read-MissionDll $old }
  $d = $(if ($oldProps) { $oldProps } else { @{ Name = $base; Map = "eden01.map"; Tech = "MULTITEK.TXT"; Type = "Colony";
                                               Players = 2; MaxTech = 12; UnitOnly = $false; AiPlayers = 0 } })
  function Get-Key([string] $key, [string] $valuePattern) {
    $m = [regex]::Match($text, "(^|[^A-Za-z0-9_])" + $key + "\s*=\s*" + $valuePattern)
    if ($m.Success) { return $m.Groups[2].Value } else { return $null }
  }
  $p = @{}
  foreach ($k in @(@("Name", "name"), @("Map", "map"), @("Tech", "tech"), @("Type", "type"))) {
    $v = Get-Key $k[1] '"([^"]*)"'; $p[$k[0]] = $(if ($null -ne $v) { $v } else { $d[$k[0]] })
  }
  foreach ($k in @(@("MaxTech", "max_tech"), @("Players", "players_count"), @("AiPlayers", "ai_players"))) {
    $v = Get-Key $k[1] '(-?[0-9]+)'; $p[$k[0]] = $(if ($null -ne $v) { [int]$v } else { $d[$k[0]] })
  }
  $v = Get-Key "unit_only" '(true|false)(?![A-Za-z0-9_])'
  $p.UnitOnly = $(if ($null -ne $v) { $v -eq "true" } else { $d.UnitOnly })

  if (-not $target) {
    $prefix = $(if ($base -cmatch '^[A-Z]' -and -not (Test-Multiplayer $p.Type)) { "c" } else { "" })
    $target = Join-Path $dir "$prefix$base.dll"
  }
  $built = New-MissionDll $p
  $leaf = Split-Path $target -Leaf
  if ($old -and $old.Length -eq $built.Length -and [Collections.StructuralComparisons]::StructuralEqualityComparer.Equals($old, $built)) {
    Write-Host "$leaf was up to date."
    return
  }
  if ($old) {
    if ([Text.Encoding]::GetEncoding(28591).GetString($old).IndexOf("OP2LuaCore.dll", [StringComparison]::OrdinalIgnoreCase) -lt 0) {
      throw "$leaf isn't an OP2Lua mission DLL, so it was left as it was."
    }
    Copy-Item $target "$target.bak" -Force
  }
  [IO.File]::WriteAllBytes($target, $built)
  if (-not $old) { Write-Host "Made $leaf."; return }
  $changes = @()
  if ($oldProps) {
    $typeOf = { param($n) $t = Get-TypeName (Get-TypeValue $n); if ($t) { $t } else { $n } }
    $pairs = @(
      @("name", "`"$($oldProps.Name)`"", "`"$($p.Name)`""), @("map", $oldProps.Map.ToLower(), $p.Map.ToLower()),
      @("tech tree", $oldProps.Tech.ToLower(), $p.Tech.ToLower()), @("type", (& $typeOf $oldProps.Type), (& $typeOf $p.Type)),
      @("max tech level", "$($oldProps.MaxTech)", "$($p.MaxTech)"), @("players", "$($oldProps.Players)", "$($p.Players)"),
      @("unit-only", "$($oldProps.UnitOnly)".ToLower(), "$($p.UnitOnly)".ToLower()),
      @("AI players", "$($oldProps.AiPlayers)", "$($p.AiPlayers)"))
    foreach ($c in $pairs) { if ($c[1] -ne $c[2]) { $changes += "$($c[0]) $($c[1]) (here $($c[2]))" } }
  }
  if ($changes) { Write-Host "Rebuilt $leaf; it had $($changes -join ', ')." } else { Write-Host "Rebuilt $leaf from the stub." }
  return
}

# --- a new mission ----------------------------------------------------------------------------------------------
if (-not $Name) { throw "Give the mission a -Name (or -DllFrom <Base.placement.lua> to rebuild a DLL)." }
$tv = Get-TypeValue $Type
if ($tv -ne 0) { $Type = Get-TypeName $tv }      # the type as the placement names it (MultiLastOneStanding, "1")
$props = @{ Name = $Name; Map = $Map; Tech = $Tech; Type = $Type; Players = $Players; MaxTech = $MaxTech;
            UnitOnly = [bool]$UnitOnly; AiPlayers = $AiPlayers }
$dll = New-MissionDll $props

# Base name = the menu name with non-alphanumerics removed. The DLL base name decides which .lua
# files it loads: cMyMission.dll -> MyMission.lua + MyMission.placement.lua (the core drops a leading c that
# comes before a capital); a base that doesn't start with a capital keeps the c in the script names too.
$base = ($Name -replace '[^A-Za-z0-9]', '')
if (-not $base) { throw "Name '$Name' has no letters/digits to form a file name." }
$multi = Test-Multiplayer $Type
if ($multi) { $dllBase = $base } else { $dllBase = "c$base" }
if ($multi -or $base -cmatch '^[A-Z]') { $scriptBase = $base } else { $scriptBase = $dllBase }

if (-not $OutDir) { $OutDir = Join-Path $sdkRoot "out" }
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
[IO.File]::WriteAllBytes((Join-Path $OutDir "$dllBase.dll"), $dll)

$extra = ""
if ($UnitOnly -or $AiPlayers -ne 0) {
  $extra = "  unit_only = $(([bool]$UnitOnly).ToString().ToLower()), ai_players = $AiPlayers,`n"
}
$header = "-- $scriptBase.placement.lua  -  $Name  -  starting layout.`n" +
          "-- Coordinates are the ones shown on the in-game status bar (hover a tile to read them).`n" +
          "return {`n" +
          "  name = `"$Name`", map = `"$Map`", tech = `"$Tech`", type = `"$Type`",`n" +
          "  max_tech = $MaxTech, players_count = $Players,`n$extra`n"

if (-not $multi) {
  $placement = $header + @"
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
  $mission = @"
-- $scriptBase.lua  -  $Name  -  mission logic.
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
} else {
  # A multiplayer type: the lobby sets each player's colony, colour and human/AI, so no players table.
  $units = ""
  for ($k = 1; $k -le $Players; $k++) { $units += "    { type = `"CommandCenter`", player = $k, at = { $(20 + 12 * ($k - 1)), 20 } },`n" }
  $placement = $header + @"
  -- No players table: in a multiplayer game the lobby has already set each player's colony and colour.

  units = {
    -- What every game starts with (player = 1..$Players). Bases that depend on the lobby's
    -- settings (game.initial_units()) are made in on_init instead.
$units  },

  beacons = {}, walls = {},
  regions = {},
  markers = {},
}
"@
  if ((Get-TypeValue $Type) -eq -8) {
    $win = "  mission.last_one_standing()   -- the game's own Last One Standing victory, per player"
  } else {
    $win = "  -- Win: this type's victory with trigger.* and mission.victory (docs/API.md, `"Multiplayer missions`")."
  }
  $mission = @"
-- $scriptBase.lua  -  $Name  -  mission logic.
-- See docs/API.md for the full API. Edit freely; this is your mission.

function on_init()
  -- The lobby's settings: game.initial_units(), game.uses_day_night(), game.uses_morale(),
  -- game.disasters_enabled(), and each player's .difficulty (the resource level).
$win
end
"@
}

# LF line endings, as the other tools write them.
[IO.File]::WriteAllText((Join-Path $OutDir "$scriptBase.placement.lua"), (($placement -replace "`r`n", "`n") + "`n"))
[IO.File]::WriteAllText((Join-Path $OutDir "$scriptBase.lua"), (($mission -replace "`r`n", "`n") + "`n"))

$typeText = $(if ($tv -gt 0) { "campaign mission $Type" } else { $Type })
$more = ""
if ($UnitOnly) { $more += ", unit-only" }
if ($AiPlayers) { $more += ", $AiPlayers AI player(s)" }
Write-Host ""
Write-Host "Created mission '$Name' in $OutDir :" -ForegroundColor Green
Write-Host "  $dllBase.dll    ($typeText, map $Map, tech $Tech, max tech level $MaxTech, $Players player(s)$more)"
Write-Host "  $scriptBase.lua    (edit your logic here)"
Write-Host "  $scriptBase.placement.lua    (edit your layout here)"
Write-Host ""
Write-Host "Next: copy all three files into your Outpost 2  OPU\maps  folder, then launch the game."
Write-Host "See ..\INSTALL.md for paths and ..\docs\GETTING-STARTED.md for the walkthrough."
