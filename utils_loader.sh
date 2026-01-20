DFLOADER() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: DFLOADER <load|unload|reload|list|show> [UTILITY_NAME [...]] [--all]" >&2
        return 1
    fi

    local mode="$1"
    case "$mode" in
        load|unload|reload|list|show) ;;
        *)
            echo "Invalid mode: $mode." >&2
            echo "Usage: DFLOADER <load|unload|reload|list|show> [UTILITY_NAME [...]] [--all]" >&2
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

    if [[ "$2" == "--all" ]]; then
        local utils_list=()
        while IFS= read -r; do
            utils_list+=("$REPLY")
        done < <(find "${utils_dir}" -maxdepth 1 -type f -exec basename {} \;)

        DFLOADER "$mode" "${utils_list[@]}"

        return 0
    fi

    local util_name_clean
    local util_name
    local util_file
    local func_names
    local alias_names
    while [[ "$#" -gt 1 ]]; do
        shift
        util_name="$1"
        util_file="${utils_dir}/${util_name}"

        if [[ ! -e "${util_file}" ]]; then
            echo "Utility not found in ${utils_dir}: ${util_name}" >&2
            return 1
        fi

        util_name_clean=$(command echo "$util_name" | command tr ' +-.!?():,;=' '_' | command tr --complement --delete "a-zA-Z0-9_" | command tr '[:upper:]' '[:lower:]')

        func_names=()
        while IFS= read -r; do
            func_names+=("$REPLY")
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
                DFLOADER "unload" "$util_name"
                DFLOADER "load" "$util_name"
                ;;
            load)
                if [[ ":${_DF_LOADED_MODULES}:" == *":${util_name_clean}:"* ]]; then
                    echo "Utility already loaded: ${util_name}"
                    continue
                fi

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
                . "${util_file}"
                if [[ -n "${_DF_LOADED_MODULES}" ]]; then
                    export _DF_LOADED_MODULES="${_DF_LOADED_MODULES}:${util_name_clean}"
                else
                    export _DF_LOADED_MODULES="${util_name_clean}"
                fi
                ;;
            unload)
                if [[ ":${_DF_LOADED_MODULES}:" != *":${util_name_clean}:"* ]]; then
                    echo "Utility not loaded: ${util_name}"
                    continue
                fi

                echo "Unloading utility: ${util_name}"
                if [[ -n "${func_names[*]}" ]]; then
                    echo "Functions:"
                    for func in "${func_names[@]}"; do
                        unset -f "$func"
                        echo " - $func"
                    done
                fi
                if [[ -n "${alias_names[*]}" ]]; then
                    echo "Aliases:"
                    for alias in "${alias_names[@]}"; do
                        unalias "$alias"
                        echo " - $alias"
                    done
                fi
                _DF_LOADED_MODULES=":${_DF_LOADED_MODULES}:"
                _DF_LOADED_MODULES=${_DF_LOADED_MODULES//:"$util_name_clean":/:}
                _DF_LOADED_MODULES=${_DF_LOADED_MODULES#:}
                _DF_LOADED_MODULES=${_DF_LOADED_MODULES%:}
                export _DF_LOADED_MODULES
                ;;
        esac
        echo ""
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
