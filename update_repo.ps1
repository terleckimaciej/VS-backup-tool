# Script to update the repository based on the current VS Code state
$ErrorActionPreference = "Stop"

$VSCodeUserDir = Join-Path $env:APPDATA "Code\User"
$RepoDir = $PSScriptRoot
$CodeCmd = Get-Command "code" -ErrorAction SilentlyContinue

Write-Host "=== Repository Update (Backup) ===" -ForegroundColor Cyan

# 1. Copying settings.json and keybindings.json from system to repo
Write-Host "Copying configuration files to repository..." -ForegroundColor Yellow
if (Test-Path (Join-Path $VSCodeUserDir "settings.json")) {
    Copy-Item (Join-Path $VSCodeUserDir "settings.json") (Join-Path $RepoDir "settings.json") -Force
}
if (Test-Path (Join-Path $VSCodeUserDir "keybindings.json")) {
    Copy-Item (Join-Path $VSCodeUserDir "keybindings.json") (Join-Path $RepoDir "keybindings.json") -Force
}

# 2. Generating extensions list
if ($CodeCmd) {
    Write-Host "Generating list of installed extensions..." -ForegroundColor Yellow
    # UTF-8 output keeps extensions.txt readable on Linux and Windows.
    & code --list-extensions | Set-Content -Path (Join-Path $RepoDir "extensions.txt") -Encoding utf8
} else {
    Write-Warning "VS Code CLI ('code') not found. Skipping extensions export."
}

Write-Host "=== Completed! ===" -ForegroundColor Green
Write-Host "Your repository is now updated. You can commit the changes." -ForegroundColor Green
