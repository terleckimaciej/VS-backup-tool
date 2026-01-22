# VS Code Configuration Manager

This project provides a simple, automated way to synchronize your Visual Studio Code environment across different Windows machines.

Instead of manually copying settings or relying on cloud sync, this tool uses a Git repository as the single source of truth for your configuration. It allows you to:

1.  **Backup** your current VS Code setup (extensions, settings, keybindings) to this repository.
2.  **Restore** that exact setup on any new machine with a single script.

It is designed to be lightweight, transparent, and version-controllable.

## Requirements

- Windows 10/11
- PowerShell 5.1 or newer
- Visual Studio Code installed

## Usage

### 1. Initialization (First Run)
If you are setting up this repository for the first time and want to save your current VS Code configuration into it:

```powershell
.\update_repo.ps1
```

This will populate the empty repository with your existing settings, keybindings, and extensions list. You can then commit these files to Git.

### 2. Restore (Apply Settings to VS Code)
Use this command when setting up a new machine or reverting changes. It will automatically backup your existing local config before overwriting it.

```powershell
.\install.ps1
```

**What it does:**
- Backs up current local settings to a `backups/` folder.
- Copies `settings.json` and `keybindings.json` from this repo to your VS Code user folder.
- Installs all extensions listed in `extensions.txt`.

### 2. Update (Save Settings to Repo)
Use this command when you have made changes to your VS Code configuration (e.g., installed a new extension) and want to save them to the repository.

```powershell
.\update_repo.ps1
```

**What it does:**
- Copies your current local `settings.json` and `keybindings.json` into this repository.
- Generates a new `extensions.txt` list based on your currently installed extensions.

## Notes

- The `backups/` folder is created locally to ensure safety but is ignored by Git to keep the repository clean.
- The system automatically keeps only the 5 most recent backups to save space.
