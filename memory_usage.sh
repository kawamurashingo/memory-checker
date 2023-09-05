#!/bin/bash

declare -A process_memory
declare -A process_cmd
declare -A process_user

total_memory_kb=$(free -k | awk '/Mem:/ {print $2}')
used_memory_kb=$(free -k | awk '/Mem:/ {print $3}')

total_memory_mb=$(echo "scale=2; $total_memory_kb/1024" | bc)
used_memory_mb=$(echo "scale=2; $used_memory_kb/1024" | bc)

memory_percentage=$(echo "scale=2; ($used_memory_kb/$total_memory_kb)*100" | bc)

for pid in $(ls /proc | grep '^[0-9]*$'); do
    if [[ -f /proc/$pid/smaps ]]; then
        memory_kb=$(awk '/Rss:/ {sum+=$2} END {print sum}' /proc/$pid/smaps)
        if (( memory_kb > 0 )); then
            memory_mb=$(echo "scale=2; $memory_kb/1024" | bc)
            cmdline=$(cat /proc/$pid/cmdline | tr '\0' ' ' | head -c 50)
            user=$(ps -o user= -p $pid | tr -d ' ')
            process_memory[$pid]=$memory_mb
            process_cmd[$pid]=$cmdline
            process_user[$pid]=$user
        fi
    fi
done 

# Memory Usedが大きい順にソートして出力
for pid in $(for key in "${!process_memory[@]}"; do echo "$key:${process_memory[$key]}"; done | sort -t: -k2 -nr | cut -d: -f1); do
    printf "User: %10s - PID: %6s - Memory Used: %6s MB - Command: %s\n" "${process_user[$pid]}" "$pid" "${process_memory[$pid]}" "${process_cmd[$pid]}"
done

echo "Total Memory: $total_memory_mb MB"
echo "Used Memory: $used_memory_mb MB"
echo "Memory Usage: $memory_percentage%"
