#!/usr/bin/env bash

install_extensions() {
    local extensions
    extensions=(
        "catppuccin.catppuccin-vsc"
        "mads-hartmann.bash-ide-vscode"
        "ms-vscode.remote-explorer"
        "ms-vscode-remote.remote-ssh"
        "ms-vscode-remote.remote-ssh-edit"
        "ms-vscode.cpptools-themes"
        "yzhang.markdown-all-in-one"
        "timonwong.shellcheck"
        "mathematic.vscode-latex"
        "james-yu.latex-workshop"
        "github.copilot-chat"
    )

    echo "Installing extensions:"
    local ext
    for ext in "${extensions[@]}"; do
        echo "- $ext"
        code --install-extension "$ext" --force
    done
    echo "All extensions installed."
}

echo "VS Code Setup"

install_extensions
