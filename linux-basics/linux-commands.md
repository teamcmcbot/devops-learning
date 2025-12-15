# Commands

`uname -r` - Displays the kernel version of the Linux operating system.
`df -h` - Shows disk space usage in a human-readable format.
`top` - Provides a dynamic, real-time view of system processes and resource usage.
`ps aux` - Lists all running processes with detailed information.
`free -m` - Displays memory usage in megabytes.
`ifconfig` - Displays network interfaces and their configurations.
`ping <hostname/IP>` - Tests connectivity to a specified host.
`netstat -tuln` - Lists all listening ports and associated services.
`chmod <permissions> <file>` - Changes the permissions of a file or directory.
`chown <owner>:<group> <file>` - Changes the owner and group of
a file or directory.
`lscpu` - Displays detailed information about the CPU architecture.
`lsblk` - Lists information about all available or specified block devices.
`dmesg` - Displays kernel-related messages, useful for troubleshooting hardware issues.
`df -hP` - Shows disk space usage in a human-readable format with POSIX compliance.
`update-alternatives --display editor` - Displays the current alternatives for the 'editor' command.

## Check for available package managers

```bash
command -v apt apt-get
command -v dnf yum
command -v zypper
command -v apk
command -v pacman
```

## Find Commands

`find /path -name <filename>` - Searches for files and directories by name starting from the specified path.
`find /path -type f -size +100M` - Finds files larger than 100MB.
`find /path -type d -perm 755` - Finds directories with specific permissions.
`find /path -mtime -7` - Finds files modified in the last 7 days.
`locate <filename>` - Quickly finds files by name using a pre-built database.

## Grep Commands

`grep 'pattern' <file>` - Searches for a specific pattern in a file.
`grep -r 'pattern' /path` - Recursively searches for a pattern in all files within a directory.
`grep -i 'pattern' <file>` - Searches for a pattern in a case-insensitive manner.
`grep -n 'pattern' <file>` - Displays line numbers along with matching lines.
`grep -v 'pattern' <file>` - Displays lines that do not match the specified pattern.
`grep -E 'pattern1|pattern2' <file>` - Uses extended regular expressions to search for multiple patterns.
`ps aux | grep 'process_name'` - Searches for a specific process in the list of running processes.
