System Audit Tool
A modular Bash-based system auditing toolkit that collects hardware and software information, generates reports, logs execution history, and optionally delivers reports via email or SSH.

Project Structure
FileRolemenu.shInteractive entry point — lets the user choose which report to runfull.shGenerates a detailed hardware + software reportsummary.shGenerates a summary hardware + software reportlogexec.shAutomated orchestrator — runs both reports non-interactively, logs events, and checksums outputsmail.shSends one or more report files via msmtpssh.shTransfers report files to a remote host via scp

Features
Hardware Detection (both full.sh and summary.sh)

CPU — model, architecture, cores/threads, MHz, cache, flags
GPU — PCI-detected display adapters
RAM — total/available memory; hardware memory banks (via dmidecode)
Motherboard — manufacturer, product, version (via dmidecode)
Disk — block devices, filesystem types, usage, inodes
Network — interface status, MAC addresses, IP addresses
USB — connected USB devices
BIOS — vendor, version, release date, characteristics
Battery — manufacturer, capacity, voltage, chemistry (via dmidecode)

Software Detection (both full.sh and summary.sh)

OS name, version, kernel, architecture, desktop environment
Installed package count (total and manually installed)
User info — current user, UID/GID, groups, logged-in users, all system users
Services — count of active services; full list (full.sh) or top 5 (summary.sh)
Processes — count; full ps aux (full.sh) or top 5 (summary.sh)
Open ports via ss -tuln

Delivery Options
Both full.sh and summary.sh prompt after displaying results:

Email — calls mail.sh, which uses msmtp with a custom subject
SSH — calls ssh.sh, which uses scp to transfer reports to a remote host

Automated Logging (logexec.sh)

Creates /var/log/sys_audit/ if it doesn't exist
Runs both report scripts non-interactively (answers n to delivery prompts)
Appends timestamped [START/SUCCESS/ERROR/INFO/FINISH] events to audit_history.log
Generates SHA-256 integrity hashes for both reports


Usage
Interactive menu
bashbash menu.sh
Choose:

1 — Full report (+ optional email/SSH)
2 — Summary report (+ optional email/SSH)
3 — Both reports

Run reports directly
bashbash full.sh       # Detailed report
bash summary.sh    # Summary report
Automated / scheduled run
bashsudo bash logexec.sh
Suitable for use in a cron job. All output is saved to /var/log/sys_audit/.

Dependencies
ToolPurposelscpu, lspci, lsusb, lsblkHardware enumerationdmidecodeDetailed hardware info (requires sudo)ip, nmcli, ssNetwork and port infosystemctl, psServices and processesdpkg, apt-markPackage informationmsmtpEmail delivery (must be configured)scp / sshRemote file transfersha256sumReport integrity verification

Output Files
All files are saved to /var/log/sys_audit/:
FileDescriptionfull_report_YYYYMMDD.txtDetailed reportshort_report_YYYYMMDD.txtSummary reportaudit_history.logTimestamped execution logintegrity_checks_full.logSHA-256 hashes for full reportsintegrity_checks_summary.logSHA-256 hashes for summary reports

Notes

Several hardware queries require sudo (dmidecode). Run with elevated privileges for complete output.
msmtp must be configured (~/.msmtprc) before email delivery will work.
SSH transfer uses scp and assumes key-based or password authentication is available to the target host.

