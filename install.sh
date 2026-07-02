#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VSCODE_USER_DIR="${VSCODE_USER_DIR:-$HOME/.config/Code/User}"
BACKUPS_ROOT="$REPO_DIR/backups"
TIMESTAMP="$(date +%Y%m%d-%H%M)"
BACKUP_DIR="$BACKUPS_ROOT/$TIMESTAMP"
MAX_BACKUPS=5

printf '=== Starting VS Code configuration restore (Linux) ===\n'

if [[ ! -d "$VSCODE_USER_DIR" ]]; then
    printf 'VS Code configuration directory not found: %s\n' "$VSCODE_USER_DIR" >&2
    exit 1
fi

mkdir -p "$BACKUP_DIR"
printf 'Creating backup of current settings in: %s\n' "$BACKUP_DIR"

if [[ -f "$VSCODE_USER_DIR/settings.json" ]]; then
    cp "$VSCODE_USER_DIR/settings.json" "$BACKUP_DIR/settings.json"
fi
if [[ -f "$VSCODE_USER_DIR/keybindings.json" ]]; then
    cp "$VSCODE_USER_DIR/keybindings.json" "$BACKUP_DIR/keybindings.json"
fi

if command -v code >/dev/null 2>&1; then
    printf 'Backing up installed extensions list...\n'
    code --list-extensions > "$BACKUP_DIR/extensions.txt"
fi

printf 'Copying configuration files...\n'
cp "$REPO_DIR/settings.json" "$VSCODE_USER_DIR/settings.json"
cp "$REPO_DIR/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"

EXTENSIONS_FILE="$REPO_DIR/extensions.txt"
if [[ -f "$EXTENSIONS_FILE" ]]; then
    if ! command -v code >/dev/null 2>&1; then
        printf "VS Code CLI ('code') not found. Skipping extensions installation.\n" >&2
    else
        printf 'Installing extensions from list...\n'
        INSTALLED_EXTENSIONS="$(code --list-extensions || true)"
        while IFS= read -r ext || [[ -n "$ext" ]]; do
            ext="${ext%$'\r'}"
            ext="$(printf '%s' "$ext" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
            ext="${ext#$'\ufeff'}"

            if [[ -z "$ext" || "$ext" == \#* ]]; then
                continue
            fi

            if grep -Fxq "$ext" <<< "$INSTALLED_EXTENSIONS"; then
                printf 'Skipped (already installed): %s\n' "$ext"
            else
                printf 'Installing: %s\n' "$ext"
                code --install-extension "$ext" --force
            fi
        done < "$EXTENSIONS_FILE"
    fi
else
    printf 'Warning: extensions.txt not found\n' >&2
fi

if [[ -d "$BACKUPS_ROOT" ]]; then
    mapfile -t backups < <(find "$BACKUPS_ROOT" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' | sort -nr | awk '{print $2}')
    if (( ${#backups[@]} > MAX_BACKUPS )); then
        printf 'Cleaning up old backups (keeping last %d)...\n' "$MAX_BACKUPS"
        for backup in "${backups[@]:MAX_BACKUPS}"; do
            printf 'Removing old backup: %s\n' "$(basename "$backup")"
            rm -rf "$backup"
        done
    fi
fi

printf '=== Completed successfully! ===\n'
printf 'Restart VS Code to apply all changes.\n'
