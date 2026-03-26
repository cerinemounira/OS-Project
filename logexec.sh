#!/bin/bash
#orchestrator of the project

#variables of dir and files
LOG_DIR="/var/log/sys_audit"
LOG_FILE="$LOG_DIR/audit_history.log"
SHORT_REPORT="$LOG_DIR/short_report_$(date +%Y%m%d).txt"
FULL_REPORT="$LOG_DIR/full_report_$(date +%Y%m%d).txt"

#variables of scripts
SHORT_SCRIPT="/proscr/summary.sh"
FULL_SCRIPT="/proscr/full.sh"

#crete parent directory if not exist
mkdir -p "$LOG_DIR" 

#mn hna mfhmtch
log_event() {
    local status="$1"
    local message="$2"
    #like inputs for the function
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$status] - $message" >> "$LOG_FILE"
}

#
log_event "START" "Automated audit initiated."

# Execute Short Report Script 
if bash "$SHORT_SCRIPT" > "$SHORT_REPORT" 2>> "$LOG_FILE"; then
    log_event "SUCCESS" "Short report generated via $SHORT_SCRIPT"
else
    log_event "ERROR" "Short report script failed execution."
fi

# Execute Full Report Script 
if bash "$FULL_SCRIPT" > "$FULL_REPORT" 2>> "$LOG_FILE"; then
    log_event "SUCCESS" "Full report generated via $FULL_SCRIPT"
else
    log_event "ERROR" "Full report script failed execution."
fi

#Integrity Check 
sha256sum "$FULL_REPORT" >> "$LOG_DIR/integrity_checks.log"
log_event "INFO" "Integrity hash generated for full report."

log_event "FINISH" "Automation cycle complete."
