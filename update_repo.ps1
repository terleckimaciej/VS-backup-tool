# Script to update the repository based on the current VS Code state
$ErrorActionPreference = "Stop"

$VSCodeUserDir = "$env:APPDATA\Code\User"
$RepoDir = $PSScriptRoot

Write-Host "=== Repository Update (Backup) ===" -ForegroundColor Cyan

# 1. Copying settings.json and keybindings.json from system to repo
Write-Host "Copying configuration files to repository..." -ForegroundColor Yellow
if (Test-Path "$VSCodeUserDir\settings.json") {
    Copy-Item "$VSCodeUserDir\settings.json" "$RepoDir\settings.json" -Force
}
if (Test-Path "$VSCodeUserDir\keybindings.json") {
    Copy-Item "$VSCodeUserDir\keybindings.json" "$RepoDir\keybindings.json" -Force
}

# 2. Generating extensions list
Write-Host "Generating list of installed extensions..." -ForegroundColor Yellow
cmd /c "code --list-extensions" > "$RepoDir\extensions.txt"

Write-Host "=== Completed! ===" -ForegroundColor Green
Write-Host "Your repository is now updated. You can commit the changes." -ForegroundColor Green
