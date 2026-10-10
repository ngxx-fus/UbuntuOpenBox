#!/bin/sh

# /*
#  * @file power.sh
#  * @brief DIY shutdown menu using rofi with dynamic callback mapping and shell fallback.
#  */

###############################################################################################
# SHELL INIT ##################################################################################
###############################################################################################

# Control flow: Check if the script is running in a shell other than zsh or bash.
if [ -z "$ZSH_VERSION" ] && [ -z "$BASH_VERSION" ]; then
    if command -v zsh >/dev/null 2>&1; then
        exec zsh "$0" "$@"
    elif command -v bash >/dev/null 2>&1; then
        exec bash "$0" "$@"
    fi
fi

# Control flow: Handle array declarations based on the active shell to ensure compatibility.
if [ -n "$ZSH_VERSION" ]; then
    typeset -a OPT_LIST
    typeset -A OPT_MAP
else
    declare -a OPT_LIST
    declare -A OPT_MAP
fi

add_option() {
    local title="$1"
    local callback="$2"
    OPT_LIST+=("$title")
    OPT_MAP["$title"]="$callback"
}

###############################################################################################
# USER DEFINITIONS ############################################################################
###############################################################################################

ROFI=/usr/bin/rofi
ROFI_TITLE="Control Panel"
ROFI_THEME="$HOME/.config/openbox/rofi/controlpanel.rasi"

# 1. Global variables for OptTitle
OP_CANCEL="󰜺  Cancel"
OP_PWR="󰾆  Power"
OP_NOTI="󰓅  Noti"

# 2. Callbacks for OptCallBack

cb_cancel() {
    exit 0
}

cb_power() {
    notify-send -u critical -i system-shutdown "System" "Opening Power Menu..."
    # Control flow: Replace current shell process with the external script.
    exec /home/fus/.config/scripts/power
}

cb_noti() {
    :
    exit 0
}

# 3. Add OptTitle and OptCallback into OptList
# (Đã fix lỗi NBSP - sử dụng khoảng trắng chuẩn)
add_option "$OP_CANCEL" "cb_cancel"
add_option "$OP_PWR" "cb_power"
add_option "$OP_NOTI" "cb_noti"

###############################################################################################
# SHELL EXEC ##################################################################################
###############################################################################################

# (Đã fix lỗi Word Splitting bằng cách bọc "$ROFI_TITLE")
chosen=$(printf '%s\n' "${OPT_LIST[@]}" | $ROFI -dmenu -i -p "$ROFI_TITLE" -line-padding 4 -hide-scrollbar -theme "$ROFI_THEME")

# Control flow: Execute callback if valid choice exists in the mapping.
if [ -n "$chosen" ] && [ -n "${OPT_MAP[$chosen]}" ]; then
    # Control flow: Call the dynamically mapped function.
    ${OPT_MAP[$chosen]}
else
    # Exit execution gracefully on cancel or unmatched input.
    exit 0
fi
