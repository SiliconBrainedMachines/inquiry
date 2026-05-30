# dev-install.ps1 — Builds and installs Inquiry CLI from source.
#
# Usage:
#   .\code\cli\scripts\dev-install.ps1
#
# What it does:
#   1. Runs build.ps1 (compile + package assets)
#   2. Copies build\ → $env:LOCALAPPDATA\inquiry\ (same layout as install.ps1)
#   3. Adds inquiry\bin\ to user PATH
#   4. Creates iq.cmd alias
#   5. Verifies with iq version
#
# Requires: Dart SDK in PATH.

$ErrorActionPreference = 'Stop'

$scriptDir = $PSScriptRoot
$cliRoot = Split-Path -Parent $scriptDir
$buildDir = Join-Path $cliRoot 'build'
$installDir = Join-Path $env:LOCALAPPDATA 'inquiry'
$binDir = Join-Path $installDir 'bin'

# ─── Build ────────────────────────────────────────────────────────────────────

Write-Host '>>> Building from source...'
& "$scriptDir\build.ps1"

# ─── Install ──────────────────────────────────────────────────────────────────

if (Test-Path $installDir) {
    Write-Host '>>> Removing previous installation...'
    Remove-Item -Recurse -Force $installDir
}

Write-Host ">>> Installing to $installDir..."
New-Item -ItemType Directory -Force -Path $binDir | Out-Null
Copy-Item (Join-Path $buildDir 'bin' 'inquiry.exe') (Join-Path $binDir 'inquiry.exe')
Copy-Item -Recurse (Join-Path $buildDir 'assets') (Join-Path $installDir 'assets')

# ─── iq alias ─────────────────────────────────────────────────────────────────

Write-Host '>>> Creating iq alias...'
Set-Content -Path (Join-Path $binDir 'iq.cmd') -Value '@"%~dp0inquiry.exe" %*' -Encoding ASCII

# ─── PATH ─────────────────────────────────────────────────────────────────────

$userPath = [System.Environment]::GetEnvironmentVariable('PATH', 'User')

$userPathEntries = @()
if (-not [string]::IsNullOrWhiteSpace($userPath)) {
    $userPathEntries = @(
        $userPath -split ';' | Where-Object { $_ -and $_ -ne $binDir }
    )
}

$updatedUserPath = (@($binDir) + $userPathEntries) -join ';'

if ($userPath -ne $updatedUserPath) {
    Write-Host '>>> Ensuring inquiry\bin\ is on PATH...'
    [System.Environment]::SetEnvironmentVariable('PATH', $updatedUserPath, 'User')
}

if (($env:PATH -split ';') -notcontains $binDir) {
    $env:PATH = "$binDir;$env:PATH"
}

# ─── Verify ───────────────────────────────────────────────────────────────────

Write-Host '>>> Verifying...'
$iqCommand = Get-Command 'iq' -CommandType Application -ErrorAction Stop
$expectedIq = Join-Path $binDir 'iq.cmd'

if ($iqCommand.Source -ne $expectedIq) {
    throw "iq resolved to '$($iqCommand.Source)' instead of '$expectedIq'"
}

$versionOutput = & $iqCommand.Source version
Write-Host "    iq -> $($iqCommand.Source)"
Write-Host "    $versionOutput"

Write-Host ''
Write-Host '>>> Installed from source successfully!'
Write-Host "    Location: $installDir"
