# not interactive = do nothing
case $- in
    *i*) ;;
    *) return;;
esac

df_bashrc_dir=$( builtin cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && builtin pwd )
. "${df_bashrc_dir}/commonrc"
unset df_bashrc_dir

df_bashrc_so() { for f in $@; do [ -s $1 ] && source "$f"; done; }
df_bashrc_so "${DOTFILES_HOME}/subbash"/*
unset -f df_bashrc_so
