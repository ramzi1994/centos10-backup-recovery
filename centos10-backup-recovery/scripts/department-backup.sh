#!/usr/bin/bash
# department-backup.sh - Automated Backup and Recovery System

SOURCE="/srv/files"
MOUNT_POINT="/backup"
BACKUP_DIR="$MOUNT_POINT/archives"
LOG_DIR="$MOUNT_POINT/logs"
LOG_FILE="$LOG_DIR/backup.log"

# Check that the dedicated backup disk is mounted.
if ! mountpoint -q "$MOUNT_POINT"; then
    echo "[$(date '+%F %T')] ERROR: Backup disk is not mounted" >&2
    exit 1
fi

# Check that the source directory exists.
if [ ! -d "$SOURCE" ]; then
    echo "[$(date '+%F %T')] ERROR: Source directory is missing" >&2
    exit 1
fi

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

# Delete matching archives older than seven 24-hour periods.
find "$BACKUP_DIR" -maxdepth 1 -type f \
    -name 'department-backup-*.tar.gz' -mtime +6 -delete

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE="$BACKUP_DIR/department-backup-$TIMESTAMP.tar.gz"

echo "[$(date '+%F %T')] Backup started" >> "$LOG_FILE"

if tar -czf "$ARCHIVE" -C /srv files; then
    if tar -tzf "$ARCHIVE" > /dev/null; then
        chmod 600 "$ARCHIVE"
        echo "[$(date '+%F %T')] SUCCESS: $ARCHIVE created and validated" >> "$LOG_FILE"
        exit 0
    else
        rm -f "$ARCHIVE"
        echo "[$(date '+%F %T')] ERROR: Archive validation failed" >> "$LOG_FILE"
        exit 1
    fi
else
    rm -f "$ARCHIVE"
    echo "[$(date '+%F %T')] ERROR: Backup creation failed" >> "$LOG_FILE"
    exit 1
fi
