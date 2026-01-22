# Skrypt przywracajacy konfiguracje VS Code z repozytorium
$ErrorActionPreference = "Stop"

$VSCodeUserDir = "$env:APPDATA\Code\User"
$RepoDir = $PSScriptRoot

Write-Host "=== Rozpoczynam przywracanie konfiguracji VS Code ===" -ForegroundColor Cyan

# 1. Sprawdzenie czy katalog uzytkownika VS Code istnieje
if (-not (Test-Path $VSCodeUserDir)) {
    Write-Error "Nie znaleziono katalogu konfiguracyjnego VS Code: $VSCodeUserDir"
    exit 1
}

# 2. Backup obecnych plikow (dla bezpieczenstwa)
$Timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$BackupDir = "$RepoDir\backups\$Timestamp"
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null
Write-Host "Tworze kopie zapasowa obecnych ustawien w: $BackupDir" -ForegroundColor Gray

if (Test-Path "$VSCodeUserDir\settings.json") {
    Copy-Item "$VSCodeUserDir\settings.json" "$BackupDir\settings.json"
}
if (Test-Path "$VSCodeUserDir\keybindings.json") {
    Copy-Item "$VSCodeUserDir\keybindings.json" "$BackupDir\keybindings.json"
}

# 3. Kopiowanie plikow konfiguracyjnych
Write-Host "Kopiowanie plikow konfiguracyjnych..." -ForegroundColor Yellow
Copy-Item "$RepoDir\settings.json" "$VSCodeUserDir\settings.json" -Force
Copy-Item "$RepoDir\keybindings.json" "$VSCodeUserDir\keybindings.json" -Force

# 4. Instalacja rozszerzen
$ExtensionsFile = "$RepoDir\extensions.txt"
if (Test-Path $ExtensionsFile) {
    Write-Host "Instalowanie rozszerzen z listy..." -ForegroundColor Yellow
    $Extensions = Get-Content $ExtensionsFile
    $InstalledExtensions = code --list-extensions
    
    foreach ($Ext in $Extensions) {
        if ($Ext -and -not ($InstalledExtensions -contains $Ext)) {
            Write-Host "Instaluje: $Ext" -ForegroundColor Cyan
            cmd /c "code --install-extension $Ext --force"
        } else {
            Write-Host "Pominieto (zainstalowane): $Ext" -ForegroundColor DarkGray
        }
    }
} else {
    Write-Warning "Nie znaleziono pliku extensions.txt"
}

Write-Host "=== Zakonczono sukcesem! ===" -ForegroundColor Green
Write-Host "Zrestartuj VS Code, aby zastosowac wszystkie zmiany." -ForegroundColor Green
