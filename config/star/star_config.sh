#!/usr/bin/env bash

# Do not set variables regarding the installation of star itself, such as:
# _STAR_HOME
# _STAR_CONFIG_HOME
# _STAR_CONFIG_FILE
# _STAR_DATA_HOME
# This configuration file is only for run-time configuration, and should be able to be quickly reloaded without breaking the installation.

# alias sl to stl and add its autocompletion
if ! alias | grep "^sl=stl$" &> /dev/null; then
    alias sl=stl
    _sl() { COMP_WORDS[0]="stl"; export COMP_WORDS; _complete_star; }
    complete -F _sl sl
fi

if ! alias | grep "^sconfig='star config'$" &> /dev/null; then
    alias sconfig='star config'
fi

if ! alias | grep "^s='star'$" &> /dev/null; then
    alias s=star
fi

# Value: yes, no (default: yes)
export __STAR_ENABLE_ENVVARS=yes

# - sta: star add
# - unstar/strm: star remove
# - stl: star load (and star list when used without arguments and __STAR_ENABLE_LOADLISTS=yes)
export __STAR_ENABLE_ALIASES=yes

# Value: yes, no (default: yes)
export __STAR_ENABLE_LOADLISTS=yes

### LIST OPTIONS ###
# default: "<INDEX>:<BR><COLNAME>%f<COLRESET><BR>-><BR><COLPATH>%l<COLRESET>"
export __STAR_LIST_FORMAT="<INDEX>:<BR><COLNAME>%f<COLRESET><BR>-><BR><COLPATH>%l<COLRESET>"
# default: "command column -t -s $'\t'"
export __STAR_LIST_COLUMN_COMMAND="command column -t -s $'\t'"

### Sorting and ordering options ###
# Value: loaded, name, none (default: loaded)
export __STAR_LIST_SORT="loaded"
# Value: asc, desc (default: desc)
export __STAR_LIST_ORDER="desc"
# Value: asc, desc (default: asc)
export __STAR_LIST_INDEX="asc"

### COLOR OPTIONS ###
# Value: ANSI escape codes for colors. Format: $'\033[...m'
# default: $'\033[38;2;255;131;0m'
export __STAR_COLOR_NAME=$'\033[38;2;255;131;0m'
# default: $'\033[38;2;1;169;130m'
export __STAR_COLOR_PATH=$'\033[38;2;1;169;130m'
# default: $'\033[0m'
export __STAR_COLOR_RESET=$'\033[0m'

# default: $'\033[38;5;214m'
export __STAR_COLOR256_NAME=$'\033[38;5;214m'
# default: $'\033[38;5;36m'
export __STAR_COLOR256_PATH=$'\033[38;5;36m'
# default: $'\033[0m'
export __STAR_COLOR256_RESET=$'\033[0m'
