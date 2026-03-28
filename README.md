# OS-Project
OS 2026 Ramazan project 
# Linux System Audit and Monitoring — Shell Scripting Project
**NSCS | Academic Year 2025/2026**

---

## Overview

This project implements an automated Linux audit system that collects hardware and software information, generates short and full reports, sends them via email, and supports scheduled automation via cron.

---

## Project Structure

```
.
├── menu.sh        # Interactive entry point (user-facing menu)
├── full.sh        # Full/detailed hardware + software report
├── summary.sh     # Short/summary hardware + software report
├── mail.sh        # Sends a report file via email (msmtp)
└── logexec.sh     # Orchestrator: runs scripts, logs events, checks integrity
```

Reports are saved to: `/var/log/sys_audit/`

---

## Requirements

- Linux distribution (Ubuntu, Kali, etc.)
- Tools used: `lscpu`, `lspci`, `lsblk`, `dmidecode`, `nmcli`, `ip`, `free`, `df`, `lsusb`, `glxinfo`, `ss`, `systemctl`, `ps`, `dpkg`, `apt-mark`, `who`, `uname`
- Email: `msmtp` must be installed and configured
- Run scripts as root (or with `sudo`) for full hardware details

### Install msmtp

```bash
sudo apt install msmtp msmtp-mta
```

### Configure msmtp (~/.msmtprc)

```
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        ~/.msmtp.log

account        gmail
host           smtp.gmail.com
port           587
from           your_email@gmail.com
user           your_email@gmail.com
password       your_app_password

account default : gmail
```

```bash
chmod 600 ~/.msmtprc
```

> Use a Gmail App Password (not your main password). Generate one at: myaccount.google.com → Security → App passwords.

---

## Installation

```bash
# Clone or copy all scripts to a directory, e.g. /proscr/
sudo mkdir -p /proscr
sudo cp *.sh /proscr/
sudo chmod +x /proscr/*.sh

# Create log directory
sudo mkdir -p /var/log/sys_audit
```

---

## How to Run

### Interactive menu (manual use)

```bash
sudo bash /proscr/menu.sh
```

Choose:
- `1` — Full report + email
- `2` — Short report + email
- `3` — Both reports + email

### Automated orchestrator (used by cron)

```bash
sudo bash /proscr/logexec.sh
```

This will:
1. Run `summary.sh` → save to `/var/log/sys_audit/short_report_YYYYMMDD.txt`
2. Run `full.sh` → save to `/var/log/sys_audit/full_report_YYYYMMDD.txt`
3. Generate SHA-256 integrity hashes → `/var/log/sys_audit/integrity_checks.log`
4. Send the full report via email
5. Log all events → `/var/log/sys_audit/audit_history.log`

---

## Automation (Cron)

To schedule `logexec.sh` to run every day at 04:00 AM:

```bash
sudo crontab -e
```

Add the following line:

```
0 4 * * * /bin/bash /proscr/logexec.sh >> /var/log/sys_audit/cron.log 2>&1
```

Save and exit. Verify with:

```bash
sudo crontab -l
```

---

## Output Files

| File | Description |
|------|-------------|
| `short_report_YYYYMMDD.txt` | Summary report (hardware + software) |
| `full_report_YYYYMMDD.txt` | Detailed report (hardware + software) |
| `audit_history.log` | Timestamped log of all script executions |
| `integrity_checks.log` | SHA-256 hashes for report verification |

---

## Notes

- `dmidecode` requires root privileges for motherboard, BIOS, RAM, and battery info.
- `glxinfo` (used in `summary.sh` for GPU) requires a display environment. It may fail in headless/SSH sessions.
- The `menu.sh` shebang line is missing the `/` (`#!bin/bash` should be `#!/bin/bash`) — fix before running.
