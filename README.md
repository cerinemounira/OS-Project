# System Audit Tool

A modular Bash-based system auditing toolkit that collects hardware and software information, generates reports, logs execution history, and optionally delivers reports via email or SSH.

---
## Installation

git clone https://github.com/cerinemounira/OS-Project.git

---
## Project Structure

| File | Role |
|------|------|
| `menu.sh` | Interactive entry point — lets the user choose which report to run |
| `full.sh` | Generates a **detailed** hardware + software report |
| `summary.sh` | Generates a **summary** hardware + software report |
| `logexec.sh` | **Automated orchestrator** — runs both reports non-interactively, logs events, and checksums outputs |
| `mail.sh` | Sends one or more report files via `msmtp` |
| `ssh.sh` | Transfers report files to a remote host via `scp` |

---

## Features

### Hardware Detection (both `full.sh` and `summary.sh`)
- **CPU** — model, architecture, cores/threads, MHz, cache, flags
- **GPU** — PCI-detected display adapters
- **RAM** — total/available memory; hardware memory banks (via `dmidecode`)
- **Motherboard** — manufacturer, product, version (via `dmidecode`)
- **Disk** — block devices, filesystem types, usage, inodes
- **Network** — interface status, MAC addresses, IP addresses
- **USB** — connected USB devices
- **BIOS** — vendor, version, release date, characteristics
- **Battery** — manufacturer, capacity, voltage, chemistry (via `dmidecode`)

### Software Detection (both `full.sh` and `summary.sh`)
- OS name, version, kernel, architecture, desktop environment
- Installed package count (total and manually installed)
- User info — current user, UID/GID, groups, logged-in users, all system users
- Services — count of active services; full list (`full.sh`) or top 5 (`summary.sh`)
- Processes — count; full `ps aux` (`full.sh`) or top 5 (`summary.sh`)
- Open ports via `ss -tuln`

### Delivery Options
Both `full.sh` and `summary.sh` prompt after displaying results:
- **Email** — calls `mail.sh`, which uses `msmtp` with a custom subject
- **SSH** — calls `ssh.sh`, which uses `scp` to transfer reports to a remote host

### Automated Logging (`logexec.sh`)
- Creates `/var/log/sys_audit/` if it doesn't exist
- Runs both report scripts non-interactively (answers `n` to delivery prompts)
- Appends timestamped `[START/SUCCESS/ERROR/INFO/FINISH]` events to `audit_history.log`
- Generates SHA-256 integrity hashes for both reports

---

## Usage

### Interactive menu
```bash
./menu.sh
```
Choose:
- `1` — Full report (+ optional email/SSH)
- `2` — Summary report (+ optional email/SSH)
- `3` — Both reports

### Run reports directly
```bash
./full.sh       # Detailed report
./summary.sh    # Summary report
```

### Automated / scheduled run
```bash
./logexec.sh
```
All output is saved to `/var/log/sys_audit/`.

### Scheduling with Cron

```bash
crontab -e
```

Add one of the following lines depending on how often you want the audit to run:

```bash
# Every day at 02:00 AM
0 2 * * * /path/to/logexec.sh >> /var/log/sys_audit/cron.log 2>&1
```

> Replace `/path/to/` with the actual directory where the scripts are located.

To **verify** the cron job was saved:
```bash
crontab -l
```

---

## Dependencies

| Tool | Purpose |
|------|---------|
| `lscpu`, `lspci`, `lsusb`, `lsblk` | Hardware enumeration |
| `dmidecode` | Detailed hardware info (requires `sudo`) |
| `ip`, `nmcli`, `ss` | Network and port info |
| `systemctl`, `ps` | Services and processes |
| `dpkg`, `apt-mark` | Package information |
| `msmtp` | Email delivery (must be configured) |
| `scp` / `ssh` | Remote file transfer |
| `sha256sum` | Report integrity verification |

---

## Output Files

All files are saved to `/var/log/sys_audit/`:

| File | Description |
|------|-------------|
| `full_report_YYYYMMDD.txt` | Detailed report |
| `short_report_YYYYMMDD.txt` | Summary report |
| `audit_history.log` | Timestamped execution log |
| `integrity_checks_full.log` | SHA-256 hashes for full reports |
| `integrity_checks_summary.log` | SHA-256 hashes for summary reports |

---

## Notes

- Several hardware queries require `sudo` (dmidecode). Run with elevated privileges for complete output.
- `msmtp` must be configured (`~/.msmtprc`) before email delivery will work.
- SSH transfer uses `scp` and assumes key-based or password authentication is available to the target host.
