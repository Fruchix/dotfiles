# not interactive = do nothing
case $- in
    *i*) ;;
    *) return;;
esac

autoload -U +X bashcompinit && bashcompinit
autoload -U +X compinit && compinit

df_zshrc_dir=$( builtin cd -- "$( dirname -- "${(%):-%x}" )" && builtin pwd )
. "${df_zshrc_dir}/commonrc"
unset df_zshrc_dir

# source all subzsh files
df_zshrc_so() { for f in $@; do [ -s $1 ] && source "$f"; done; }
df_zshrc_so "${DOTFILES_HOME}/subzsh"/*
unset -f df_zshrc_so
