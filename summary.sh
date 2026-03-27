#!/bin/bash

#HARD PART
function cpu(){
    echo -e "\n*************** CPU *************** \n"
    lscpu | grep -E "Model name|Architecture"
    lscpu | grep -E '^Thread|^Core|^Socket|^CPU\(' | head -n3
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | awk -F. '{print $1}')
    if [ "$cpu_usage" -gt 80 ]; then
        echo "Alert: CPU usage is at ${cpu_usage}%"
    fi
}

function gpu(){
    echo -e "\n*************** GPU *************** \n"
    glxinfo | grep "Device"
}

function ram(){
    echo -e "\n*************** RAM *************** \n"
    echo -e "Total Memory :$(free -h | grep "Mem" | awk '/Mem/ {print$2}')"
    echo -e "Available Memory :$(free -h | grep "Mem" | awk '/Mem/ {print$7}')"
}

function disk(){
    echo -e "\n*************** DISK *************** \n"
    df -T | awk '{print$1,$2,$4,$5,$7,$8}' | column -t
    ##lsblk -o NAME,SIZE,MOUNTPOINT
    ##df -h | awk '{print $1, $3, $5, $6}' | column -t
}

function network(){
    echo -e "\n*************** NETWORK *************** \n"
    ##ip -brief addr show | awk 'BEGIN {printf "%-15s %-10s %-20s\n", "INTERFACE", "STATUS", "IP ADDRESS"; print "------------------------------------------------------------"} {printf "%-15s %-10s %-20s\n", $1, $2, $3}'
    ip -brief addr show | awk 'BEGIN {printf "%-15s %-10s %-20s %-20s\n", "INTERFACE", "STATUS", "MAC ADDRESS", "IP ADDRESS"; print "--------------------------------------------------------------------"} { "cat /sys/class/net/"$1"/address" | getline mac; printf "%-15s %-10s %-20s %-20s\n", $1, $2, mac, $3}'
}

function mother(){
    echo -e "\n*************** MOTHERBOARD *************** \n"
    sudo dmidecode -t 2 | grep -E "Manufacturer|Product|Version"
}

function usb(){
    echo -e "\n*************** USB *************** \n"
    lsusb
}

function bios(){
    echo -e "\n*************** BIOS *************** \n"
    sudo dmidecode -t 0 | grep -E "Vendor|Version|ROM"
}

function battery(){
    echo -e "\n*************** BATTERY *************** \n"
    sudo dmidecode -t 22 | grep -E "Location|Manufacturer|Name|Design|Chemistry"
}

function displayhard(){
    echo "-----------------------------"
    echo "      HARDWARE SUMMARY       "
    echo "-----------------------------"

    cpu
    gpu
    ram
    disk
    network
    usb
    mother
    bios
    battery
    echo -e " ********* END OF REPORT ********* \n"
}

#display "short" >> "$FULL_REPORT_FILE" 2>> "$LOG_FILE"
 
######################################################################

#SOFT PART 


function os(){
    echo -e "********** OS INFORMATION **********"
    grep "^NAME=" /etc/os-release | tr -d '"' 
    grep "^VERSION=" /etc/os-release
}

function arc(){
    echo -e "********** SYSTEM INFORMATION **********"
    echo "KERNEL VERSION="$(uname -r)
    echo "System Architecture : "$(uname -m)
    echo "Desktop : $XDG_SESSION_DESKTOP"
}

function pro(){
    echo "********** INSTALLED PROGRAMMES **********"
    echo "Number of installed packages : "$(dpkg -l | wc -l)

    echo "Manual installed programmes :"
    apt-mark showmanual | paste -sd ', '
}

function use(){
    echo -e "********** USER INFORMATION **********"
    echo "Current user: "$(whoami)
    echo "Logged-in users:"
    who
    echo "Number of All system users:" $(cut -d: -f1 /etc/passwd | wc -l)
    
}

function sepr(){
    echo -e "********** SERVECIES AND PROCESSES **********"
    echo "   ---- Services ----"
    echo "Number of Active Services : "$(systemctl list-units --type=service --state=running | wc -l)
    echo "Top 5 Running Services : "
    systemctl list-units --type=service --state=running | tail -n +2 | head -n 5

    echo
    echo "   ---- Processes ----"
    echo "Number of Processes : "$(ps aux | wc -l)
    echo "Top 5 Processes :"
    ps aux | tail -n +2 | head -n 5
}


function op(){
    echo -e "********** OPEN PORT **********"
    ss -tuln 
}

 
function displaysoft(){
    echo "-----------------------------"
    echo "      SOFTWARE SUMMARY       "
    echo "-----------------------------"

    echo
    echo "HOSTNAME:"$(hostname)
    #echo "DATE:"$(date)
    echo
    os
    echo
    arc
    echo
    pro 
    echo
    use
    echo
    sepr
    echo
    op
}
#display
displaysoft
displayhard
#send through email
name_short=short_report_$(date +%Y%m%d).txt
./mail.sh name_short

