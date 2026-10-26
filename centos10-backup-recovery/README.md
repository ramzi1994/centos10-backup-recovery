# Automated Backup and Recovery System (CentOS Stream 10)

Mini project for a Linux Administration lab. A dedicated XFS disk stores daily, validated,
timestamped `tar.gz` backups of departmental files. A systemd timer runs the backup at 2:00 AM,
and a recovery test restores the files to confirm the backups work.

**Phases**

1. **Backup disk** - 10 GiB disk `/dev/sdb`, GPT, XFS, persistent UUID mount at `/backup`.
2. **Users and access** - groups `hr`, `it`, `finance`; folders under `/srv/files` with mode `2770` (group access + setgid).
3. **Backup script** - mount check, source check, 7-day retention, `tar.gz` creation, validation, logging.
4. **Automation and recovery** - `department-backup.service` (oneshot) + `department-backup.timer` (daily 02:00, `Persistent=true`), restore test.

## Repository layout

```
scripts/
  01-prepare-backup-disk.sh        Phase 1 (destructive - read before running)
  02-create-users-and-folders.sh   Phase 2
  03-install-backup-service.sh     Phases 3-4 install + enable timer
  04-recovery-test.sh              Validate newest archive and restore to /tmp
  department-backup.sh             The backup script itself
systemd/
  department-backup.service
  department-backup.timer
docs/
  Project_Report.docx              Full project report
```

## Requirements

CentOS Stream 10 (VMware VM), a second empty 10 GiB disk (`/dev/sdb`), root/sudo access.
Tools: Bash, GNU tar, XFS utilities, util-linux (`mountpoint`), find, systemd, journalctl.

## Quick start

```bash
git clone https://github.com/<your-username>/centos10-backup-recovery.git
cd centos10-backup-recovery

sudo ./scripts/01-prepare-backup-disk.sh /dev/sdb   # ERASES /dev/sdb - type YES to confirm
sudo ./scripts/02-create-users-and-folders.sh
sudo passwd hruser; sudo passwd ituser; sudo passwd financeuser
sudo ./scripts/03-install-backup-service.sh

sudo systemctl start department-backup.service       # manual run
sudo systemctl status department-backup.service --no-pager -l
sudo ls -lhtr /backup/archives
sudo tail -n 10 /backup/logs/backup.log

sudo ./scripts/04-recovery-test.sh
```

Expected recovery output:

```
HR employee records - test data
IT server inventory - test data
Finance budget records - test data
```

## Security notes

- `/backup/archives` and `/backup/logs` are `700`, archives are `600` - only root can read them.
- The script checks `mountpoint -q /backup` **before** any write, so backups cannot silently land on the root disk.
- Sample data is demonstration content only.

## Test status

Passed: disk mount, fstab verify, script syntax, service run, archive creation and contents, log entries,
recovery, timer enabled and active.
**Not yet tested:** retention deletion of genuinely old archives, and the missing-mount failure path
(plan this so the active timer cannot run during the test).

## Limitations / future work

Local backup only: no off-site copy, encryption, email alerts or disk-capacity monitoring. A separate
virtual disk does not protect against loss of the host storage. Ideas: SHA-256 checksums, replication
to another host, failure alerts, encryption, daily/weekly/monthly retention.
