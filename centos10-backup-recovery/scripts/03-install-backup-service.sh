#!/usr/bin/bash
# Phases 3-4: install the backup script, systemd service and timer, then enable the timer.
# Run from the repository root:  sudo ./scripts/03-install-backup-service.sh
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Run as root (sudo)."; exit 1; }

install -o root -g root -m 700 scripts/department-backup.sh /usr/local/sbin/department-backup.sh
bash -n /usr/local/sbin/department-backup.sh

install -o root -g root -m 644 systemd/department-backup.service /etc/systemd/system/
install -o root -g root -m 644 systemd/department-backup.timer   /etc/systemd/system/

systemctl daemon-reload
systemctl enable --now department-backup.timer

systemctl is-enabled department-backup.timer
systemctl is-active  department-backup.timer
systemctl list-timers department-backup.timer
