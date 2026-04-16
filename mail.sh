#!/bin/bash

REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

read -p "Enter recipient email: " EMAIL

if [[ ! "$EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]];
 then
  echo "Invalid email format"
  exit 1
fi

read -p "Enter a subject (leave empty as default): " SUBJECT
if [ -z "$SUBJECT" ]; then
  SUBJECT="System Report -- $(hostname) -- $(date)"
fi

TMPFILE=$(mktemp)

{
    echo "To: $EMAIL"
    echo "Subject: $SUBJECT"
    echo ""          

    for file in "$@"; do
      if [ -f "$file" ]; then
        cat "$file"
        echo
      fi
    done
} > "$TMPFILE"


sudo -u "$REAL_USER" msmtp "$EMAIL" < "$TMPFILE"

rm -f "$TMPFILE"
