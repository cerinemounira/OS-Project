#!/bin/bash

read -p "Enter username :" user
read -p "Enter IP address :" ip

REMOTE_USER="$user"     
REMOTE_HOST="$ip"    


REMOTE_DIRS="/home/$REMOTE_USER/sshreportS.txt"
REMOTE_DIRF="/home/$REMOTE_USER/sshreportF.txt"


DATE=$(date +%Y%m%d)
FULL_REPORT="/var/log/sys_audit/full_report_$(date +%Y%m%d).txt"
SHORT_REPORT="/var/log/sys_audit/short_report_$(date +%Y%m%d).txt"



echo "INFO" "Starting remote transfer..."


if scp "$FULL_REPORT" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIRF"; then
    echo "SUCCESS" "Full report sent to $REMOTE_HOST"
else
    echo "ERROR" "Failed to send full report"
fi


if scp "$SHORT_REPORT" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIRS"; then
    echo "SUCCESS" "Short report sent to $REMOTE_HOST"
else
    echo "ERROR" "Failed to send short report"
fi

echo "FINISH" "Remote transfer completed."
