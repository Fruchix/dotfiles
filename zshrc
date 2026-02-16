# not interactive = do nothing
case $- in
    *i*) ;;
    *) return;;
esac

df_zshrc_dir=$( builtin cd -- "$( dirname -- "${(%):-%x}" )" && builtin pwd )
. "${df_zshrc_dir}/commonrc"
unset df_zshrc_dir
