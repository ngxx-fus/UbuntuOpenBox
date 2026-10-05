#!/usr/bin/env bash

###################################################################################################
# CONFIG
###################################################################################################

# Set where to save the project mode index (0-indexed for rofi)
PROJECT_MODE="/tmp/projectmode"
TIMEOUT_SEC=15

# Auto-detect internal display (eDP, LVDS)
INTERNAL=$(xrandr --query | grep " connected" | grep -E -m 1 "^(eDP|LVDS)" | awk '{print $1}')

# Auto-detect first connected external display (excludes INTERNAL)
EXTERNAL=$(xrandr --query | grep " connected" | grep -v "^$INTERNAL" | head -n 1 | awk '{print $1}')

# Menu options matching Windows + P
OPTIONS_ARR=(
    "1. PC screen only"
    "2. Duplicate"
    "3. Extend"
    "4. Second screen only"
)
OPTIONS=$(printf "%s\n" "${OPTIONS_ARR[@]}")

# Read previously selected index, defaulting to 0
CURRENT_INDEX=0
if [ -f "$PROJECT_MODE" ]; then
    CURRENT_INDEX=$(cat "$PROJECT_MODE")
fi

# Calculate next index in cycle (0 -> 1 -> 2 -> 3 -> 0)
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % 4 ))

###################################################################################################
# ACTION
###################################################################################################

# Fallback check if no external monitor is plugged in
if [ -z "$EXTERNAL" ]; then
    xrandr --output "$INTERNAL" --auto --primary
    exit 0
fi

# Prompt via rofi with timeout
CHOICE=$(echo -e "$OPTIONS" | timeout "$TIMEOUT_SEC" rofi -dmenu -i -selected-row "$NEXT_INDEX" -p "Project (${TIMEOUT_SEC}s)" -theme /home/fus/.config/openbox/rofi/popup.rasi)
EXIT_CODE=$?

# If timed out (exit code 124), auto-select the highlighted mode
if [ "$EXIT_CODE" -eq 124 ]; then
    CHOICE="${OPTIONS_ARR[$NEXT_INDEX]}"
# If cancelled by user pressing Esc (exit code 1), abort cleanly
elif [ "$EXIT_CODE" -ne 0 ] || [ -z "$CHOICE" ]; then
    exit 0
fi

case "$CHOICE" in
    "1. PC screen only")
        xrandr --output "$INTERNAL" --auto --primary --output "$EXTERNAL" --off
        echo 0 > "$PROJECT_MODE"
        ;;
    "2. Duplicate")
        xrandr --output "$INTERNAL" --auto --output "$EXTERNAL" --auto --same-as "$INTERNAL"
        echo 1 > "$PROJECT_MODE"
        ;;
    "3. Extend")
        xrandr --output "$INTERNAL" --auto --primary --output "$EXTERNAL" --auto --right-of "$INTERNAL"
        echo 2 > "$PROJECT_MODE"
        ;;
    "4. Second screen only")
        xrandr --output "$INTERNAL" --off --output "$EXTERNAL" --auto --primary
        echo 3 > "$PROJECT_MODE"
        ;;
esac

# Restart polybar to match the updated display state
/home/fus/.config/openbox/polybar/polybar-ob &