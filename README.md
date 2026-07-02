# VS-settings-backup-tool

**Git-Based VS Code Configuration Manager**

This tool provides a simple, automated way to synchronize your Visual Studio Code environment (settings, keybinds and extensions) across different machines (Windows and Linux) using a Git repository as the single source of truth.

## Why use this?

While VS Code has a built-in "Settings Sync", the tool offers a transparent, file-based alternative for the full control. It is particularly useful if you want to:

- **Sync without accounts:** Easily transfer your personal configuration to a work laptop where logging in with a personal account is restricted.
- **Version control your settings:** Track changes to your `settings.json` over time using Git history.
- **Avoid cloud dependency:** Keep your configuration backup strictly under your own control.

## Requirements

### Windows
- Windows 10/11
- PowerShell 5.1 or newer
- Visual Studio Code installed

### Linux
- Bash
- Visual Studio Code installed
- `code` CLI available in PATH (run "Shell Command: Install 'code' command in PATH" in VS Code if needed)

## Usage

### 1. Initialization (First Run)
If you are setting up this repository for the first time and want to save your current VS Code configuration into it:

Windows:
```powershell
.\update_repo.ps1
```

Linux:
```bash
chmod +x ./update_repo.sh ./install.sh
./update_repo.sh
```

This will populate the repository (or rather replace author's config ;) with your existing settings, keybindings, and extensions list. You can then commit these files to Git.

### 2. Restore (Apply Settings to VS Code)
Use this command when setting up a new machine or reverting changes. It will automatically backup your existing local config before overwriting it.

Windows:
```powershell
.\install.ps1
```

Linux:
```bash
./install.sh
```

**What it does:**
- Backs up current local settings to a `backups/` folder.
- Copies `settings.json` and `keybindings.json` from this repo to your VS Code user folder.
- Installs all extensions listed in `extensions.txt`.

### 3. Update (Save Settings to Repo)
Use this command when you have made changes to your VS Code configuration (e.g., installed a new extension) and want to save them to the repository.

Windows:
```powershell
.\update_repo.ps1
```

Linux:
```bash
./update_repo.sh
```

**What it does:**
- Copies your current local `settings.json` and `keybindings.json` into this repository.
- Generates a new `extensions.txt` list based on your currently installed extensions.

## Notes

- Linux scripts use `~/.config/Code/User` by default. If needed, you can override this path using `VSCODE_USER_DIR`.
- The `backups/` folder is created locally to ensure safety but is ignored by Git to keep the repository clean.
- The system automatically keeps only the 5 most recent backups to save space.
