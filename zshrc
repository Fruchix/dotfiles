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

HIST_STAMPS="yyyy-mm-dd"

[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
[ "$HISTSIZE" -lt 1000000 ] && HISTSIZE=1000000
[ "$SAVEHIST" -lt 1000000 ] && SAVEHIST=1000000

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

# omz config: $ZSH should point to omz installation
if [[ -f "$ZSH"/oh-my-zsh.sh ]]; then
   ZSH_THEME="robbyrussell"

   zstyle ':omz:update' mode auto

   plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
   . "$ZSH"/oh-my-zsh.sh
fi
