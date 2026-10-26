#!/usr/bin/bash
# Phase 1: partition, format (XFS) and mount the dedicated backup disk.
# WARNING: this ERASES the target disk. Default is /dev/sdb. Never use the system disk.
set -euo pipefail

DISK="${1:-/dev/sdb}"
PART="${DISK}1"

[ "$(id -u)" -eq 0 ] || { echo "Run as root (sudo)."; exit 1; }
[ -b "$DISK" ] || { echo "$DISK is not a block device."; exit 1; }

lsblk -f "$DISK"
read -r -p "This will DESTROY all data on $DISK. Type YES to continue: " ans
[ "$ans" = "YES" ] || { echo "Aborted."; exit 1; }

parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart backup xfs 1MiB 100%
partprobe "$DISK"; sleep 2
mkfs.xfs "$PART"

mkdir -p /backup
mount "$PART" /backup

UUID=$(blkid -s UUID -o value "$PART")
echo "UUID=$UUID  /backup  xfs  defaults  0 0" >> /etc/fstab
systemctl daemon-reload
findmnt --verify
mountpoint /backup

mkdir -p /backup/archives /backup/logs
chown root:root /backup/archives /backup/logs
chmod 700 /backup/archives /backup/logs
echo "Backup disk ready at /backup (UUID=$UUID)."
