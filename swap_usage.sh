#!/bin/bash

total_swap_kb=$(free -k | awk '/Swap:/ {print $2}')
used_swap_kb=$(free -k | awk '/Swap:/ {print $3}')

total_swap_mb=$(awk "BEGIN {printf \"%.2f\", ($total_swap_kb/1024)}")
used_swap_mb=$(awk "BEGIN {printf \"%.2f\", ($used_swap_kb/1024)}")

swap_percentage=$(awk "BEGIN {printf \"%.2f\", ($used_swap_kb/$total_swap_kb)*100}")

for pid in $(ls /proc | grep '^[0-9]*$'); do
    if [[ -f /proc/$pid/smaps && -f /proc/$pid/status ]]; then
        swap_kb=$(awk '/Swap:/ {sum+=$2} END {print sum}' /proc/$pid/smaps 2>/dev/null)
        if [[ "$swap_kb" =~ ^[0-9]+$ ]] && (( $swap_kb > 0 )); then
            swap_mb=$(awk "BEGIN {printf \"%.2f\", ($swap_kb/1024)}")
            uid=$(awk '/^Uid:/ {print $2}' /proc/$pid/status)
            user=$(getent passwd $uid | cut -d: -f1)
            cmdline=$(cat /proc/$pid/cmdline | tr '\0' ' ' | head -c 50)
            printf "User: %10s - PID: %6s - Swap Used: %6s MB - Command: %s\n" "$user" "$pid" "$swap_mb" "$cmdline"
        fi
    fi
done | sort -n -k6,6

echo "Total Swap: $total_swap_mb MB"
echo "Used Swap: $used_swap_mb MB"
echo "Swap Usage: $swap_percentage%"
