#!/usr/bin/env bash

# Kiểm tra adapter Bluetooth có bật không
if [ "$(bluetoothctl show 2>/dev/null | grep -i "Powered: yes")" = "" ]; then
    echo "%{F#4e5b55}󰂲 Off%{F-}"
    exit 0
fi

# Lấy địa chỉ MAC của thiết bị đang kết nối
DEVICE_MAC=$(bluetoothctl devices Connected 2>/dev/null | head -n 1 | cut -d ' ' -f 2)

# Nếu không có thiết bị nào kết nối
if [ -z "$DEVICE_MAC" ]; then
    echo "%{F#50a5f5}󰂯%{F-} On"
    exit 0
fi

# Lấy tên thiết bị
DEVICE_NAME=$(bluetoothctl info "$DEVICE_MAC" 2>/dev/null | grep "Alias:" | cut -d ' ' -f 2-)
[ -z "$DEVICE_NAME" ] && DEVICE_NAME=$(bluetoothctl info "$DEVICE_MAC" 2>/dev/null | grep "Name:" | cut -d ' ' -f 2-)

# Lấy phần trăm pin từ bluetoothctl hoặc upower
BATTERY_LEVEL=$(bluetoothctl info "$DEVICE_MAC" 2>/dev/null | grep "Battery Percentage" | awk -F'[()]' '{print $2}')

if [ -z "$BATTERY_LEVEL" ]; then
    BATTERY_LEVEL=$(upower -e 2>/dev/null | grep -i "dev_${DEVICE_MAC//:/_}" | xargs -I {} upower -i {} 2>/dev/null | grep "percentage:" | awk '{print $2}')
fi

# Xuất định dạng hiển thị ra Polybar
if [ -n "$BATTERY_LEVEL" ]; then
    echo "%{F#52bdff}󰂱%{F-} $DEVICE_NAME %{F#ebf831}($BATTERY_LEVEL)%{F-}"
else
    echo "%{F#52bdff}󰂱%{F-} $DEVICE_NAME"
fi
