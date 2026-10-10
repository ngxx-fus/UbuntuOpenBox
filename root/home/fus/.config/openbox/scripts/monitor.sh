

###################################################################################################
# DETECT MONITOR
#   - This section for user-configuration
#   - POSITION LIST (z-reading)
#           P0    P1
#           P2    P3
#   - POSITION LIST (z-reading)
#           P0    P1    P2
#           P3    P4    P5
#           P6    P7    P8
#   - User will choose the 
###################################################################################################

EXEC_ROFI="/usr/bin/rofi"
DIR_MONITOR_STATE="/tmp/.monitorstate"
LIST_MODE=(
    "PC screen only"
    "Duplicate"
    "Extend >"
    "Second screen only >"
)

LIST_POS=(
    "P0"
    "P1"
    "P2"
    "P3"
    "P4"
    "P5"
    "P6"
    "P7"
    "P8"
)

###################################################################################################
# DETECT MONITOR
#   - This section will be implemented script to detect the monitor
#   - MONITOR0 is always for built-in monitor
#   - MINOTOR1, MINOTOR2 for the external monitor
###################################################################################################

MONITOR0=""
MONITOR1=""
MONITOR2=""