#!/usr/bin/env bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


unsetup_inputrc() {
    local dotfiles_inputrc="${script_dir}/inputrc"

    # if the installed inputrc is not linked to the one from those dotfiles
    # then do not remove it
    if [[ ! -L "$HOME/.inputrc" || ! -e "$HOME/.inputrc" ]] || ! diff -q "$HOME/.inputrc" "${dotfiles_inputrc}"; then
        return 0
    fi

    rm "$HOME/.inputrc"

    local bak_inputrc
    bak_inputrc="$(printf '%s\n' "$HOME/.inputrc.bak."* | sort -r | head -n 1)"

    if [[ -z "$bak_inputrc" || ! -f "$bak_inputrc" ]]; then
        return 0
    fi

    mv "$bak_inputrc" "$HOME/.inputrc"
}

unsetup_bashrc() {
    sed -i '/Fruchix\/dotfiles:install.sh/d' "$HOME/.bashrc"

    # remove bashrc if empty
    if [[ -z "$(cat "$HOME/.bashrc")" ]]; then
        rm "$HOME/.bashrc"
    fi
}

unsetup_zshrc() {
    sed -i '/Fruchix\/dotfiles:install.sh/d' "$HOME/.zshrc"

    # remove zshrc if empty
    if [[ -z "$(cat "$HOME/.zshrc")" ]]; then
        rm "$HOME/.zshrc"
    fi
}

unsetup_siu() {
    if [[ ! -d "$HOME/.siu" ]]; then
        return 0
    fi

    if ! ./"$HOME"/.siu/uninstall; then
        rm -rf "$HOME/.siu"
    fi
}

unsetup_inputrc
unsetup_bashrc
unsetup_zshrc
unsetup_siu

