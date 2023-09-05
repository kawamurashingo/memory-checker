# Swap Usage Per Process Script

This script displays the swap usage for each process in MB. Additionally, it informs the user about the total swap usage and utilization percentage for the system.

## Requirements

- Linux OS
- Bash shell
- Commands: `free`, `awk`, `getent`

## Usage

1. Make the script file (saved as something like `swap_usage.sh`) executable:

   ```
   chmod +x swap_usage.sh
   ```

2. Execute the script:

   ```
   ./swap_usage.sh
   ```

3. The output will be displayed in the following format:

   ```
   User:     root - PID:   1234 - Swap Used:   2.20 MB - Command: /path/to/command arg1 arg2
   User:    user1 - PID:   5678 - Swap Used:   1.10 MB - Command: /path/to/another-command arg1
   ...
   Total Swap: 4096.00 MB
   Used Swap: 100.00 MB
   Swap Usage: 2.44%
   ```

## Notes

- It's recommended to run this script with root permissions to gather information from all processes.
- The script is primarily designed for Linux environments.

