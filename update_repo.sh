#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VSCODE_USER_DIR="${VSCODE_USER_DIR:-$HOME/.config/Code/User}"

printf '=== Repository Update (Backup) - Linux ===\n'

printf 'Copying configuration files to repository...\n'
if [[ -f "$VSCODE_USER_DIR/settings.json" ]]; then
    cp "$VSCODE_USER_DIR/settings.json" "$REPO_DIR/settings.json"
fi
if [[ -f "$VSCODE_USER_DIR/keybindings.json" ]]; then
    cp "$VSCODE_USER_DIR/keybindings.json" "$REPO_DIR/keybindings.json"
fi

if command -v code >/dev/null 2>&1; then
    printf 'Generating list of installed extensions...\n'
    code --list-extensions > "$REPO_DIR/extensions.txt"
else
    printf "VS Code CLI ('code') not found. Skipping extensions export.\n" >&2
fi

printf '=== Completed! ===\n'
printf 'Your repository is now updated. You can commit the changes.\n'
