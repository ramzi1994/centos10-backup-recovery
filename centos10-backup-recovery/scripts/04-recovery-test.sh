#!/usr/bin/bash
# Recovery test: validate the newest archive and restore it into a temporary directory
# (live files are not touched), then print the restored sample files.
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Run as root (sudo)."; exit 1; }

ARCHIVE=$(ls -1t /backup/archives/department-backup-*.tar.gz 2>/dev/null | head -n 1 || true)
[ -n "$ARCHIVE" ] || { echo "No archive found in /backup/archives."; exit 1; }
echo "Using archive: $ARCHIVE"

tar -tzf "$ARCHIVE"

DEST=/tmp/backup-recovery-final
mkdir -p "$DEST"
tar -xzf "$ARCHIVE" -C "$DEST"

cat "$DEST/files/hr/hr_records.txt"
cat "$DEST/files/it/it_inventory.txt"
cat "$DEST/files/finance/finance_budget.txt"
