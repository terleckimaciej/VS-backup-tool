# Script to restore VS Code configuration from the repository
$ErrorActionPreference = "Stop"

$VSCodeUserDir = "$env:APPDATA\Code\User"
$RepoDir = $PSScriptRoot

Write-Host "=== Starting VS Code configuration restore ===" -ForegroundColor Cyan

# 1. Check if VS Code user directory exists
if (-not (Test-Path $VSCodeUserDir)) {
    Write-Error "VS Code configuration directory not found: $VSCodeUserDir"
    exit 1
}

# 2. Backup current files (for safety)
$Timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$BackupDir = "$RepoDir\backups\$Timestamp"
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
Write-Host "Creating backup of current settings in: $BackupDir" -ForegroundColor Gray

if (Test-Path "$VSCodeUserDir\settings.json") {
    Copy-Item "$VSCodeUserDir\settings.json" "$BackupDir\settings.json"
}
if (Test-Path "$VSCodeUserDir\keybindings.json") {
    Copy-Item "$VSCodeUserDir\keybindings.json" "$BackupDir\keybindings.json"
}

# Backup extensions list
if (Get-Command "code" -ErrorAction SilentlyContinue) {
    Write-Host "Backing up installed extensions list..." -ForegroundColor Gray
    cmd /c "code --list-extensions" > "$BackupDir\extensions.txt"
}

# 3. Copying configuration files
Write-Host "Copying configuration files..." -ForegroundColor Yellow
Copy-Item "$RepoDir\settings.json" "$VSCodeUserDir\settings.json" -Force
Copy-Item "$RepoDir\keybindings.json" "$VSCodeUserDir\keybindings.json" -Force

# 4. Installing extensions
$ExtensionsFile = "$RepoDir\extensions.txt"
if (Test-Path $ExtensionsFile) {
    Write-Host "Installing extensions from list..." -ForegroundColor Yellow
    $Extensions = Get-Content $ExtensionsFile
    $InstalledExtensions = code --list-extensions
    
    foreach ($Ext in $Extensions) {
        if ($Ext -and -not ($InstalledExtensions -contains $Ext)) {
            Write-Host "Installing: $Ext" -ForegroundColor Cyan
            cmd /c "code --install-extension $Ext --force"
        } else {
            Write-Host "Skipped (already installed): $Ext" -ForegroundColor DarkGray
        }
    }
} else {
    Write-Warning "File extensions.txt not found"
}

# 5. Cleanup old backups (keep last 5)
$MaxBackups = 5
$BackupsList = Get-ChildItem -Path "$RepoDir\backups" -Directory | Sort-Object CreationTime -Descending
if ($BackupsList.Count -gt $MaxBackups) {
    Write-Host "Cleaning up old backups (keeping last $MaxBackups)..." -ForegroundColor Yellow
    $BackupsList | Select-Object -Skip $MaxBackups | ForEach-Object {
        Write-Host "Removing old backup: $($_.Name)" -ForegroundColor DarkGray
        Remove-Item -Path $_.FullName -Recurse -Force
    }
}

Write-Host "=== Completed successfully! ===" -ForegroundColor Green
Write-Host "Restart VS Code to apply all changes." -ForegroundColor Green
