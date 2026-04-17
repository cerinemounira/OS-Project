#!/bin/bash
#orchestrator of the project

LOG_DIR="/var/log/sys_audit"
LOG_FILE="$LOG_DIR/audit_history.log"
SHORT_REPORT="$LOG_DIR/short_report_$(date +%Y%m%d).txt"
FULL_REPORT="$LOG_DIR/full_report_$(date +%Y%m%d).txt"

SHORT_SCRIPT="$(dirname "$0")/summary.sh"
FULL_SCRIPT="$(dirname "$0")/full.sh"
MAIL_SCRIPT="$(dirname "$0")/mail.sh"

#dirname gives only the directory path (.)
#$0 gives the path of the current file (./file)
#dirname "$0" gives the directory path of the current file or dir

sudo mkdir -p "$LOG_DIR"

log_event() {
    local status="$1"
    local message="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$status] - $message" >> "$LOG_FILE"
}

log_event "START" "Automated audit initiated."

if echo "n" | bash "$SHORT_SCRIPT" > "$SHORT_REPORT" 2>> "$LOG_FILE"; then
    log_event "SUCCESS" "Short report generated: $SHORT_REPORT"
else
    log_event "ERROR" "Short report script failed."
fi

#n is for input

if echo "n" | bash "$FULL_SCRIPT" > "$FULL_REPORT" 2>> "$LOG_FILE"; then
    log_event "SUCCESS" "Full report generated: $FULL_REPORT"
else
    log_event "ERROR" "Full report script failed."
fi

sha256sum "$FULL_REPORT" >> "$LOG_DIR/integrity_checks_full.log" 2>> "$LOG_FILE"
sha256sum "$SHORT_REPORT" >> "$LOG_DIR/integrity_checks_summary.log" 2>> "$LOG_FILE"
log_event "INFO" "Integrity hashes generated for both reports."

log_event "FINISH" "Automation cycle complete."

