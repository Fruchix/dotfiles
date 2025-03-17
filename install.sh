#!/usr/bin/env bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if grep -q Fruchix/dotfiles:install.sh "$HOME/.bashrc"; then
    echo -e "File '$HOME/.bashrc' is already sourcing Fruchix's dotfiles with the following lines:\n"
    grep --color=always Fruchix/dotfiles:install.sh "$HOME/.bashrc"

    # echo -e "\nInstallation already done. Exiting process."
    exit 1
else
    cat << EOF >> "$HOME/.bashrc"

### Automaticaly added by Fruchix/dotfiles:install.sh ###
source $script_dir/bashrc   ### Automaticaly added by Fruchix/dotfiles:install.sh
### Automaticaly added by Fruchix/dotfiles:install.sh ###

EOF

    echo "Added sourcing of '$script_dir/bashrc' in '$HOME/.bashrc'"
fi

if [[ ! -d $HOME/.siu ]]; then
    git clone https://github.com/Fruchix/SIU.git
    pushd SIU
    ./install.sh
    popd

    source $HOME/.siu/siu_bashrc
    $HOME/.siu/bin/siu install -M
fi
