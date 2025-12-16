#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="/var/www/html/media"
BACKUP_DIR="/backup"
ARCHIVE_NAME="xfusioncorp_media.zip"
LOCAL_ARCHIVE="${BACKUP_DIR}/${ARCHIVE_NAME}"

REMOTE_USER="clint"
REMOTE_HOST="stbkp01"
REMOTE_DIR="/backup"
REMOTE_TARGET="${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/"

# Basic checks (no sudo)
command -v zip >/dev/null 2>&1 || { echo "ERROR: zip is not installed."; exit 1; }
[[ -d "$SRC_DIR" ]] || { echo "ERROR: Source directory not found: $SRC_DIR"; exit 1; }
[[ -d "$BACKUP_DIR" ]] || { echo "ERROR: Backup directory not found: $BACKUP_DIR"; exit 1; }

# Create zip (store paths as media/... instead of full /var/www/html/...)
tmp_zip="${LOCAL_ARCHIVE}.tmp"
rm -f "$tmp_zip"
(
  cd /var/www/html
  zip -r "$tmp_zip" "media" >/dev/null
)
mv -f "$tmp_zip" "$LOCAL_ARCHIVE"

# Copy to Nautilus Backup Server (no password prompts)
scp -q -o BatchMode=yes "$LOCAL_ARCHIVE" "$REMOTE_TARGET"

echo "Backup completed successfully: $LOCAL_ARCHIVE to $REMOTE_TARGET"