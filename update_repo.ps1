# Skrypt aktualizujący repozytorium na podstawie obecnego stanu VS Code
$ErrorActionPreference = "Stop"

$VSCodeUserDir = "$env:APPDATA\Code\User"
$RepoDir = $PSScriptRoot

Write-Host "=== Aktualizacja repozytorium (Backup) ===" -ForegroundColor Cyan

# 1. Kopiowanie settings.json i keybindings.json z systemu do repo
Write-Host "Kopiowanie plików konfiguracyjnych do repozytorium..." -ForegroundColor Yellow
if (Test-Path "$VSCodeUserDir\settings.json") {
    Copy-Item "$VSCodeUserDir\settings.json" "$RepoDir\settings.json" -Force
}
if (Test-Path "$VSCodeUserDir\keybindings.json") {
    Copy-Item "$VSCodeUserDir\keybindings.json" "$RepoDir\keybindings.json" -Force
}

# 2. Generowanie listy rozszerzeń
Write-Host "Generowanie listy zainstalowanych rozszerzeń..." -ForegroundColor Yellow
cmd /c "code --list-extensions" > "$RepoDir\extensions.txt"

Write-Host "=== Zakończono! ===" -ForegroundColor Green
Write-Host "Twoje repozytorium jest teraz zaktualizowane. Możesz wykonać git commit." -ForegroundColor Green
