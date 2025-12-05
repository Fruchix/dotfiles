#!/usr/bin/env bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

setup_inputrc()
{
    if [[ -e "$HOME/.inputrc" ]]; then
        # overwrite the file only if it isnt the same
        if diff -q "$HOME/.inputrc" inputrc; then
            echo "inputrc is already linked."
            return
        fi

        date=$(date '+%Y-%m-%d_%H:%M:%S')
        echo "Archiving $HOME/.inputrc into $HOME/.inputrc.bak.${date}"
        mv "$HOME/.inputrc" "$HOME/.inputrc.bak.${date}"
    fi

    echo "Linking $HOME/.inputrc to ${script_dir}/inputrc"
    ln -s "${script_dir}/inputrc" "$HOME/.inputrc"
}

setup_bashrc()
{
    if grep -q Fruchix/dotfiles:install.sh "$HOME/.bashrc"; then
        echo -e "File '$HOME/.bashrc' is already sourcing Fruchix's dotfiles with the following lines:\n"
        grep --color=always Fruchix/dotfiles:install.sh "$HOME/.bashrc"
    else
        cat << EOF >> "$HOME/.bashrc"

### Automaticaly added by Fruchix/dotfiles:install.sh ###
source $script_dir/bashrc   ### Automaticaly added by Fruchix/dotfiles:install.sh
### Automaticaly added by Fruchix/dotfiles:install.sh ###

EOF
        echo "Added sourcing of '$script_dir/bashrc' in '$HOME/.bashrc'"
    fi
}

setup_zshrc()
{
    if grep -q Fruchix/dotfiles:install.sh "$HOME/.zshrc"; then
        echo -e "File '$HOME/.zshrc' is already sourcing Fruchix's dotfiles with the following lines:\n"
        grep --color=always Fruchix/dotfiles:install.sh "$HOME/.zshrc"
    else
        cat << EOF >> "$HOME/.zshrc"

### Automaticaly added by Fruchix/dotfiles:install.sh ###
source $script_dir/zshrc   ### Automaticaly added by Fruchix/dotfiles:install.sh
### Automaticaly added by Fruchix/dotfiles:install.sh ###

EOF
        echo "Added sourcing of '$script_dir/zshrc' in '$HOME/.zshrc'"
    fi
}

setup_siu()
{
    if [[ ! -d $HOME/.siu ]]; then
        git clone https://github.com/Fruchix/SIU.git
        ./SIU/install

        source $HOME/.siu/siu_bashrc
        # $HOME/.siu/bin/siu install -M
        echo "[SIU] Install missing softwares using: siu install -M"
    fi
}

echo "--------------------"
setup_inputrc
echo "--------------------"
setup_bashrc
echo "--------------------"
setup_zshrc
echo "--------------------"
setup_siu
echo "--------------------"
