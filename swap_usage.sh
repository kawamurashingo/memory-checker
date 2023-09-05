#!/bin/bash

declare -A process_swap
declare -A process_cmd
declare -A process_user

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
            process_swap[$pid]=$swap_mb
            process_cmd[$pid]=$cmdline
            process_user[$pid]=$user
        fi
    fi
done 

# Swap Usedが大きい順にソートして出力
for pid in $(for key in "${!process_swap[@]}"; do echo "$key:${process_swap[$key]}"; done | sort -t: -k2 -nr | cut -d: -f1); do
    printf "User: %10s - PID: %6s - Swap Used: %6s MB - Command: %s\n" "${process_user[$pid]}" "$pid" "${process_swap[$pid]}" "${process_cmd[$pid]}"
done

echo "Total Swap: $total_swap_mb MB"
echo "Used Swap: $used_swap_mb MB"
echo "Swap Usage: $swap_percentage%"
