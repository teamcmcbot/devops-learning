#! /bin/bash
# Updated for Amazon Linux 2023 compatibility
sudo dnf update -y
# Remove any existing MariaDB libs (skip if not found)
sudo rpm -e --nodeps mariadb-libs-* 2>/dev/null || true
# Install MariaDB 10.5 client (provides mysql command)
sudo dnf install -y mariadb105
# Verify MySQL client installation
mysql --version
# Install telnet
sudo dnf install -y telnet