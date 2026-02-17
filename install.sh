#!/usr/bin/env bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

setup_inputrc()
{
    local dotfiles_inputrc="${script_dir}/inputrc"

    if [[ -e "$HOME/.inputrc" ]]; then
        # overwrite the file only if it isnt the same
        if diff -q "$HOME/.inputrc" "${dotfiles_inputrc}"; then
            echo "inputrc is already linked."
            return
        fi

        date=$(date '+%Y-%m-%d_%H:%M:%S')
        echo "Archiving $HOME/.inputrc into $HOME/.inputrc.bak.${date}"
        mv "$HOME/.inputrc" "$HOME/.inputrc.bak.${date}"
    fi

    echo "Linking $HOME/.inputrc to ${dotfiles_inputrc}"
    ln -s "${dotfiles_inputrc}" "$HOME/.inputrc"
}

setup_bashrc()
{
    if ! grep -q Fruchix/dotfiles:install.sh "$HOME/.bashrc"; then
        cat << EOF >> "$HOME/.bashrc"

### Automatically added by Fruchix/dotfiles:install.sh ###
source $script_dir/bashrc   ### Automatically added by Fruchix/dotfiles:install.sh
### Automatically added by Fruchix/dotfiles:install.sh ###

EOF
        echo "Added sourcing of '$script_dir/bashrc' in '$HOME/.bashrc'"
    fi
}

setup_zshrc()
{
    if ! grep -q Fruchix/dotfiles:install.sh "$HOME/.zshrc"; then
        cat << EOF >> "$HOME/.zshrc"

### Automatically added by Fruchix/dotfiles:install.sh ###
source $script_dir/zshrc   ### Automatically added by Fruchix/dotfiles:install.sh
### Automatically added by Fruchix/dotfiles:install.sh ###

EOF
        echo "Added sourcing of '$script_dir/zshrc' in '$HOME/.zshrc'"
    fi
}

setup_siu()
{
    if [[ ! -d $HOME/.siu ]]; then
        git clone https://github.com/Fruchix/SIU.git
        ./SIU/install

        # shellcheck disable=SC1091
        source "$HOME/.siu/siu_bashrc"
        # $HOME/.siu/bin/siu install -M
        echo "[SIU] Install missing softwares using: siu install -M"
    fi
}

install_vim_plugins()
{
    local vim_dir="$script_dir/config/vim"
    local autoload_dir="$vim_dir/autoload"
    local plug_file="$autoload_dir/plug.vim"
    local vimrc_file="$vim_dir/vimrc"

    echo "Installing Vim plugins."

    if [[ ! -f "$plug_file" ]]; then
        echo "Downloading vim-plug..."
        curl -fLo "$plug_file" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    echo "Running PlugInstall."
    vim -es -u "$vimrc_file" -i NONE -c "PlugInstall" -c "qa"

    echo "Finished installing Vim pluggins."
}

run_setup_command() {
    local setup_cmd="$1"

    while true; do
        echo -n "Run $setup_cmd? [y/N] "
        read -r
        case $REPLY in
            [Yy]|[Yy][Ee][Ss])
                $setup_cmd
                break
                ;;
            [Nn]|[Nn][Oo]|"")
                break
                ;;
            *) echo "Not a valid answer.";;
        esac
    done
}

setup_inputrc
setup_bashrc
run_setup_command setup_zshrc
run_setup_command setup_siu

. "${script_dir}/commonrc"

echo ""
install_vim_plugins
