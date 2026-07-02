# Script to restore VS Code configuration from the repository
$ErrorActionPreference = "Stop"

$VSCodeUserDir = Join-Path $env:APPDATA "Code\User"
$RepoDir = $PSScriptRoot
$CodeCmd = Get-Command "code" -ErrorAction SilentlyContinue

Write-Host "=== Starting VS Code configuration restore ===" -ForegroundColor Cyan

# 1. Check if VS Code user directory exists
if (-not (Test-Path $VSCodeUserDir)) {
    Write-Error "VS Code configuration directory not found: $VSCodeUserDir"
    exit 1
}

# 2. Backup current files (for safety)
$Timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$BackupDir = Join-Path $RepoDir "backups\$Timestamp"
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
Write-Host "Creating backup of current settings in: $BackupDir" -ForegroundColor Gray

$LocalSettings = Join-Path $VSCodeUserDir "settings.json"
$LocalKeybindings = Join-Path $VSCodeUserDir "keybindings.json"

if (Test-Path $LocalSettings) {
    Copy-Item $LocalSettings (Join-Path $BackupDir "settings.json")
}
if (Test-Path $LocalKeybindings) {
    Copy-Item $LocalKeybindings (Join-Path $BackupDir "keybindings.json")
}

# Backup extensions list in UTF-8 for cross-platform compatibility
if ($CodeCmd) {
    Write-Host "Backing up installed extensions list..." -ForegroundColor Gray
    & code --list-extensions | Set-Content -Path (Join-Path $BackupDir "extensions.txt") -Encoding utf8
}

# 3. Copying configuration files
Write-Host "Copying configuration files..." -ForegroundColor Yellow
Copy-Item (Join-Path $RepoDir "settings.json") $LocalSettings -Force
Copy-Item (Join-Path $RepoDir "keybindings.json") $LocalKeybindings -Force

# 4. Installing extensions
$ExtensionsFile = Join-Path $RepoDir "extensions.txt"
if (Test-Path $ExtensionsFile) {
    if (-not $CodeCmd) {
        Write-Warning "VS Code CLI ('code') not found. Skipping extensions installation."
    } else {
        Write-Host "Installing extensions from list..." -ForegroundColor Yellow
        $Extensions = Get-Content $ExtensionsFile |
            ForEach-Object { ($_.Trim() -replace "^\uFEFF", "") } |
            Where-Object { $_ -and -not $_.StartsWith("#") }
        $InstalledExtensions = @(& code --list-extensions)

        foreach ($Ext in $Extensions) {
            if (-not ($InstalledExtensions -contains $Ext)) {
                Write-Host "Installing: $Ext" -ForegroundColor Cyan
                & code --install-extension $Ext --force
            } else {
                Write-Host "Skipped (already installed): $Ext" -ForegroundColor DarkGray
            }
        }
    }
} else {
    Write-Warning "File extensions.txt not found"
}

# 5. Cleanup old backups (keep last 5)
$BackupsRoot = Join-Path $RepoDir "backups"
$MaxBackups = 5
if (Test-Path $BackupsRoot) {
    $BackupsList = Get-ChildItem -Path $BackupsRoot -Directory | Sort-Object CreationTime -Descending
    if ($BackupsList.Count -gt $MaxBackups) {
        Write-Host "Cleaning up old backups (keeping last $MaxBackups)..." -ForegroundColor Yellow
        $BackupsList | Select-Object -Skip $MaxBackups | ForEach-Object {
            Write-Host "Removing old backup: $($_.Name)" -ForegroundColor DarkGray
            Remove-Item -Path $_.FullName -Recurse -Force
        }
    }
}

Write-Host "=== Completed successfully! ===" -ForegroundColor Green
Write-Host "Restart VS Code to apply all changes." -ForegroundColor Green
