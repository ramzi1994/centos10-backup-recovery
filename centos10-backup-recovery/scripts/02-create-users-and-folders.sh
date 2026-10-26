#!/usr/bin/bash
# Phase 2: departmental groups, users, folders (mode 2770 = setgid + rwx owner/group) and sample data.
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Run as root (sudo)."; exit 1; }

for d in hr it finance; do
    getent group "$d" >/dev/null || groupadd "$d"
done

id hruser      >/dev/null 2>&1 || useradd -m -g hr      hruser
id ituser      >/dev/null 2>&1 || useradd -m -g it      ituser
id financeuser >/dev/null 2>&1 || useradd -m -g finance financeuser

mkdir -p /srv/files/{hr,it,finance}
chown root:hr      /srv/files/hr
chown root:it      /srv/files/it
chown root:finance /srv/files/finance
chmod 2770 /srv/files/hr /srv/files/it /srv/files/finance

echo 'HR employee records - test data'    > /srv/files/hr/hr_records.txt
echo 'IT server inventory - test data'    > /srv/files/it/it_inventory.txt
echo 'Finance budget records - test data' > /srv/files/finance/finance_budget.txt

ls -ld /srv/files/*
echo
echo "Now set passwords:  sudo passwd hruser; sudo passwd ituser; sudo passwd financeuser"
