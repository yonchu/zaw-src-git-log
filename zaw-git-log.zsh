#
# zaw-src-git-log
#
#   zaw source for git log.
#
#   zaw : https://github.com/nakamuray/zaw
#

# git log pretty format: For detail, refer to "man git-log"
ZAW_SRC_GIT_LOG_LOG_FORMAT=${ZAW_SRC_GIT_LOG_LOG_FORMAT:-'%ad | %s %d[%an]'}

# If true, print full SHA.
ZAW_SRC_GIT_LOG_NO_ABBREV=${ZAW_SRC_GIT_LOG_NO_ABBREV:-'false'}

# Limit the number of commits to output.
# If set the value less than 1, output unlimitedly.
ZAW_SRC_GIT_LOG_MAX_COUNT=${ZAW_SRC_GIT_LOG_MAX_COUNT:-100}

# Date style (relative, local, iso, rfc, short, raw, default)
ZAW_SRC_GIT_LOG_DATE_STYLE=${ZAW_SRC_GIT_LOG_DATE_STYLE:-'short'}

# The function to regiter to zaw.
function zaw-src-git-log () {
    # Check git directory.
    git rev-parse -q --is-inside-work-tree > /dev/null 2>&1 || return 1

    # Set up option.
    local -a opt
    opt=("--pretty=format:%h $ZAW_SRC_GIT_LOG_LOG_FORMAT")
    if [ "$ZAW_SRC_GIT_LOG_NO_ABBREV" != 'false' ]; then
        opt+=('--no-abbrev')
    fi
    if [ $ZAW_SRC_GIT_LOG_MAX_COUNT -gt 0 ]; then
        opt+=("--max-count=$ZAW_SRC_GIT_LOG_MAX_COUNT")
    fi
    if [ -n "$ZAW_SRC_GIT_LOG_DATE_STYLE" ]; then
        opt+=("--date=$ZAW_SRC_GIT_LOG_DATE_STYLE")
    fi

    # Get git log.
    local log="$(git log "${opt[@]}")"

    # Set candidates.
    candidates+=(${(f)log})
    actions=("zaw-src-git-log-append-to-buffer")
    act_descriptions=("git-log for zaw")
    # Enale multi marker.
    options+=(-m)
}
# Action function.
function zaw-src-git-log-append-to-buffer () {
    local list
    local item
    for item in "$@"; do
        list+="$(echo "$item" | cut -d ' ' -f 1) "
    done
    set -- $list

    local buf=
    if [ $# -eq 2 ]; then
        # To diff.
        buf+="$1..$2"
    else
        # 1 or 3 or more items.
        buf+="${(j: :)@}"
    fi
    # Append left buffer.
    LBUFFER+="$buf"
}
# Register this src to zaw.
zaw-register-src -n git-log zaw-src-git-log

