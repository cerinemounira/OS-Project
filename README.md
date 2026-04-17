# Linux System Audit and Monitoring — Shell Scripting Project

**NSCS | Academic Year 2025/2026**

---

## Overview

This project implements an automated Linux system audit tool that collects detailed hardware and software information, generates structured reports, sends them via email or SSH, and supports scheduled automation via cron jobs.

---

## Project Structure

```
.
├── menu.sh        # Interactive entry point (user-facing menu)
├── full.sh        # Full/detailed hardware + software report
├── summary.sh     # Short/summary hardware + software report
├── mail.sh        # Sends a report file via email (msmtp)
├── ssh.sh         # Sends a report file to a remote machine via SCP
└── logexec.sh     # Orchestrator: runs scripts, logs events, checks integrity
```

Reports are saved to: `/var/log/sys_audit/`

---

## Requirements

- Linux distribution (Ubuntu, Kali, Debian-based, etc.)
- Run scripts as **root** or with `sudo` for full hardware access
- Tools used: `lscpu`, `lspci`, `lsblk`, `dmidecode`, `nmcli`, `ip`, `free`, `df`, `lsusb`, `ss`, `systemctl`, `ps`, `dpkg`, `apt-mark`, `who`, `uname`, `msmtp`, `scp`

---

## Email Setup (msmtp)

### Install

```bash
sudo apt install msmtp msmtp-mta
```

### Configure `~/.msmtprc`

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

> Use a Gmail **App Password**, not your account password.  
> Generate one at: **Google Account → Security → 2-Step Verification → App Passwords**

---

## SSH Setup (Remote Transfer)

### 1. Install SSH Server on the Remote Machine

```bash
sudo apt update
sudo apt install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

Verify it's running:

```bash
sudo systemctl status ssh
```

### 2. Generate an SSH Key on the Local Machine

```bash
ssh-keygen
```

### 3. Copy the Public Key to the Remote Machine

```bash
ssh-copy-id user@remote_ip
```

### 4. Test the Connection

```bash
ssh user@remote_ip
```

If you log in without a password — SSH is configured correctly ✔

### 5. Configure `ssh.sh`

Edit the variables at the top of `ssh.sh` with your actual values:

```bash
REMOTE_USER="your_username"
REMOTE_HOST="192.168.1.100"
REMOTE_DIR="/home/your_username/reports"
```

---

## Installation

```bash
# Clone the repository
git clone https://github.com/your_username/your_repo.git
cd your_repo

# Make all scripts executable
chmod +x *.sh

# Create log directory
sudo mkdir -p /var/log/sys_audit
```

---

## How to Run

### Interactive Menu (Manual Use)

```bash
sudo bash menu.sh
```

| Choice | Action |
|--------|--------|
| `1` | Full report — optionally send via email or SSH |
| `2` | Short report — optionally send via email or SSH |
| `3` | Both reports — optionally send via email or SSH |

### Automated Orchestrator (Used by Cron)

```bash
sudo bash logexec.sh
```

This will:
1. Run `summary.sh` → save to `/var/log/sys_audit/short_report_YYYYMMDD.txt`
2. Run `full.sh` → save to `/var/log/sys_audit/full_report_YYYYMMDD.txt`
3. Compute SHA-256 integrity hashes → saved to `integrity_checks_full.log` and `integrity_checks_summary.log`
4. Log all events with timestamps → `/var/log/sys_audit/audit_history.log`

---

## Automation (Cron)

`logexec.sh` can be scheduled to run automatically every day at **08:40 AM**:

```bash
sudo crontab -e
```

Add the following line (replace `/path/to/logexec.sh` with the actual path to the script):

```
40 8 * * * /path/to/logexec.sh 2>> /var/log/sys_audit/cron.log
```

Save and verify:

```bash
sudo crontab -l
```

---

## Output Files

| File | Description |
|------|-------------|
| `short_report_YYYYMMDD.txt` | Summary hardware + software report |
| `full_report_YYYYMMDD.txt` | Detailed hardware + software report |
| `audit_history.log` | Timestamped log of all script executions |
| `integrity_checks_full.log` | SHA-256 hash of the full report |
| `integrity_checks_summary.log` | SHA-256 hash of the summary report |
| `cron.log` | Errors captured from cron-scheduled runs |

---

## Notes

- `dmidecode` requires **root privileges** to read motherboard, BIOS, RAM, and battery info.
- `ssh.sh` currently only transfers the **full report**. To also transfer the short report, duplicate the `scp` block and point it to `$SHORT_REPORT`.

