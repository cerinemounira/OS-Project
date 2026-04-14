#!/bin/bash

# ==============================
# Remote Report Sender Script
# ==============================

LOG_DIR="/var/log/sys_audit"
LOG_FILE="$LOG_DIR/audit_history.log"

REMOTE_USER="user"      #replace it with real hostname 
REMOTE_HOST="192.168.1.100"    # replace it with real ip@
REMOTE_DIR="/home/user/reports"


DATE=$(date +%Y%m%d)
FULL_REPORT="$LOG_DIR/full_report_$DATE.txt"
SHORT_REPORT="$LOG_DIR/short_report_$DATE.txt"

mkdir -p "$LOG_DIR"

log_event() {
    local status="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$status] - $message" >> "$LOG_FILE"
}

log_event "INFO" "Starting remote transfer..."


if scp "$FULL_REPORT" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"; then
    log_event "SUCCESS" "Full report sent to $REMOTE_HOST"
else
    log_event "ERROR" "Failed to send full report"
fi

log_event "FINISH" "Remote transfer completed."
