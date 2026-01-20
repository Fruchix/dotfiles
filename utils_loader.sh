DFLOADER() {
    local usage_oneline="Usage: DFLOADER <load|unload|reload|list|show> [UTILITY_NAME [...]] [--all] [--quiet]"
    if [[ $# -lt 1 ]]; then
        echo "$usage_oneline" >&2
        return 1
    fi

    local mode="$1"
    case "$mode" in
        load|unload|reload|list|show)
            shift
            ;;
        *)
            echo "Invalid mode: $mode." >&2
            echo "$usage_oneline" >&2
            return 1
            ;;
    esac

    if [[ -z "$DOTFILES_HOME" ]]; then
        echo "Error: DOTFILES_HOME is not set." >&2
        return 1
    fi

    local utils_dir="${DOTFILES_HOME}/utils"

    if [[ "$mode" == "list" ]]; then
        local utils_list=()

        while IFS= read -r; do
            # Extract just the star name from each line
            utils_list+=("$REPLY")
        done < <(command find "${utils_dir}" -maxdepth 1 -type f -exec basename {} \;)

        local loaded_utilities=()
        local unloaded_utilities=()
        local util_name
        local util_name_clean
        for util_name in "${utils_list[@]}"; do
            util_name_clean=$(command echo "$util_name" | command tr ' +-.!?():,;=' '_' | command tr --complement --delete "a-zA-Z0-9_" | command tr '[:upper:]' '[:lower:]')

            if [[ ":${_DF_LOADED_MODULES}:" == *":${util_name_clean}:"* ]]; then
                loaded_utilities+=("$util_name_clean")
            else
                unloaded_utilities+=("$util_name_clean")
            fi
        done

        echo "Loaded utilities: ${loaded_utilities[*]}"
        echo "Unloaded utilities: ${unloaded_utilities[*]}"

        return 0
    fi

    # all other modes
    local option_all=0
    local option_quiet=0

    local utils_positional_args=()
    while [[ $# -gt 0 ]]; do
        opt="$1";
        shift;
        case "$opt" in
            -- ) break 2;;
            - ) break 2;;
            -a|--all )  option_all=1    ;;
            -q|--quiet )option_quiet=1  ;;
            -*)
                echo "Invalid option: $opt" >&2
                return 1
                ;;
            *)
                utils_positional_args+=("$opt")
            ;;
        esac
    done

    local utils_list=()
    if [[ "$option_all" -eq 1 ]]; then
        while IFS= read -r; do
            utils_list+=("$REPLY")
        done < <(find "${utils_dir}" -maxdepth 1 -type f -exec basename {} \;)
    else
        utils_list=("${utils_positional_args[@]}")
    fi

    local util_name_clean
    local util_name
    local util_file
    local func_names
    local alias_names
    local tmp_var
    for util_name in "${utils_list[@]}"; do
        util_file="${utils_dir}/${util_name}"

        if [[ ! -e "${util_file}" ]]; then
            echo "Utility not found in ${utils_dir}: ${util_name}" >&2
            return 1
        fi

        util_name_clean=$(command echo "$util_name" | command tr ' +-.!?():,;=' '_' | command tr --complement --delete "a-zA-Z0-9_" | command tr '[:upper:]' '[:lower:]')

        func_names=()
        while IFS= read -r; do
            tmp_var="$REPLY"

            # remove leading whitespace characters
            tmp_var="${tmp_var#"${tmp_var%%[![:space:]]*}"}"
            # remove trailing whitespace characters
            tmp_var="${tmp_var%"${tmp_var##*[![:space:]]}"}"

            func_names+=("$tmp_var")
        done < <(awk '
/^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\)[[:space:]]*\{/ {
    sub(/^[[:space:]]*/, "");
    sub(/\(.*/, "");
    print;
}
/^[[:space:]]*function[[:space:]]+[a-zA-Z_][a-zA-Z0-9_]*/ {
    sub(/^[[:space:]]*function[[:space:]]+/, "");
    sub(/[[:space:]].*/, "");
    print;
}
' "${util_file}" 2>/dev/null)

        alias_names=()
        while IFS= read -r; do
            alias_names+=("$REPLY")
        done < <(awk '/^[[:space:]]*alias[[:space:]]+[A-Za-z_][A-Za-z0-9_]*=/ {
    sub(/^[[:space:]]*alias[[:space:]]+/, "");
    sub(/=.*/, "");
    print;
}' "${util_file}" 2>/dev/null)
        case "$mode" in
            show)
                echo "Utility: ${util_file}"
                if [[ "${#func_names[@]}" -gt 0 ]]; then
                    echo "Functions:"
                    for func in "${func_names[@]}"; do
                        echo " - $func"
                    done
                fi
                if [[ "${#alias_names[@]}" -gt 0 ]]; then
                    echo "Aliases:"
                    for alias in "${alias_names[@]}"; do
                        echo " - $alias"
                    done
                fi
                ;;
            reload)
                if [[ "$option_quiet" -eq 1 ]]; then
                    DFLOADER "unload" "$util_name" --quiet
                    DFLOADER "load" "$util_name" --quiet
                else
                    DFLOADER "unload" "$util_name"
                    DFLOADER "load" "$util_name"
                fi
                ;;
            load)
                if [[ ":${_DF_LOADED_MODULES}:" == *":${util_name_clean}:"* ]]; then
                    [[ "$option_quiet" -ne 1 ]] && echo "Utility already loaded: ${util_name}"
                    continue
                fi

                if [[ "$option_quiet" -ne 1 ]]; then
                    echo "Loading utility: ${util_name}"
                    if [[ "${#func_names[@]}" -gt 0 ]]; then
                        echo "Functions:"
                        for func in "${func_names[@]}"; do
                            echo " - $func"
                        done
                    fi
                    if [[ "${#alias_names[@]}" -gt 0 ]]; then
                        echo "Aliases:"
                        for alias in "${alias_names[@]}"; do
                            echo " - $alias"
                        done
                    fi
                    echo ""
                fi
                . "${util_file}"
                if [[ -n "${_DF_LOADED_MODULES}" ]]; then
                    export _DF_LOADED_MODULES="${_DF_LOADED_MODULES}:${util_name_clean}"
                else
                    export _DF_LOADED_MODULES="${util_name_clean}"
                fi
                ;;
            unload)
                if [[ ":${_DF_LOADED_MODULES}:" != *":${util_name_clean}:"* ]]; then
                    [[ "$option_quiet" -ne 1 ]] && echo "Utility not loaded: ${util_name}"
                    continue
                fi

                if [[ "$option_quiet" -ne 1 ]]; then
                    echo "Unloading utility: ${util_name}"
                    if [[ -n "${func_names[*]}" ]]; then
                        echo "Functions:"
                        for func in "${func_names[@]}"; do
                            echo " - $func"
                        done
                    fi
                    if [[ -n "${alias_names[*]}" ]]; then
                        echo "Aliases:"
                        for alias in "${alias_names[@]}"; do
                            echo " - $alias"
                        done
                    fi
                    echo ""
                fi

                if [[ -n "${func_names[*]}" ]]; then
                    for func in "${func_names[@]}"; do
                        unset -f "$func"
                    done
                fi
                if [[ -n "${alias_names[*]}" ]]; then
                    for alias in "${alias_names[@]}"; do
                        unalias "$alias"
                    done
                fi
                _DF_LOADED_MODULES=":${_DF_LOADED_MODULES}:"
                _DF_LOADED_MODULES=${_DF_LOADED_MODULES//:"$util_name_clean":/:}
                _DF_LOADED_MODULES=${_DF_LOADED_MODULES#:}
                _DF_LOADED_MODULES=${_DF_LOADED_MODULES%:}
                export _DF_LOADED_MODULES
                ;;
        esac
    done
}

_complete_DFLOADER() {
    local cur_word="${COMP_WORDS[COMP_CWORD]}"
    local commands="load unload reload list show"

    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${commands}" -- "${cur_word}") )
    elif [[ ${COMP_CWORD} -gt 1 && ${COMP_WORDS[1]} != "list" ]]; then
        local utils_dir="${DOTFILES_HOME}/utils"
        local utils_list
        utils_list="$(find "${utils_dir}" -maxdepth 1 -type f -exec basename {} \;)"
        COMPREPLY=( $(compgen -W "${utils_list}" -- "${cur_word}") )
    fi
}

complete -F _complete_DFLOADER -o nospace DFLOADER
