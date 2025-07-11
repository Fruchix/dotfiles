# not interactive = do nothing
case $- in
    *i*) ;;
    *) return;;
esac

so() { for f in $@; do [ -s $1 ] && source "$f"; done; }

script_dir="${0:a:h}"

so "${script_dir}/aliases.d"/*
so "${script_dir}/completion.d"/*
so "${script_dir}/functions.d"/*

unset script_dir
unset -f so
