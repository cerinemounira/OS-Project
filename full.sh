#!/bin/bash

#HARD PART
cpu_det() {
    echo -e "\n*************** CPU *************** \n"
    lscpu | grep -iE "Model name|Architecture|CPU\(s\):|Thread\(s\) per core|Core\(s\) per socket|CPU MHz|L[1-3][di]? cache"
    lscpu | grep Flags
}

gpu_det() {
    echo -e "\n*************** GPU *************** \n"
    lspci -nnk | grep -iA 3 "vga\|3d\|display" || echo "No dedicated GPU detected via PCI."
    echo ""
}

network_det() {
    echo -e "\n*************** NETWORK *************** \n"
    nmcli device status 2>/dev/null || ip -brief link show
    echo -e "\nDetailed Interface Config:"
    ip addr show | grep -E "link/ether|inet "
    echo ""
}

ram_det() {
    echo -e "\n*************** RAM *************** \n"
    free -h -t
    echo -e "\nHardware Memory Banks:"
    sudo dmidecode -t memory 2>/dev/null | grep -E "Size|Type|Speed|Manufacturer" || echo "Run with sudo for memory bank details."
    echo ""
}

mother_det() {
    echo -e "\n*************** MOTHERBOARD *************** \n"
    sudo dmidecode -t baseboard 2>/dev/null | grep -E "Manufacturer|Product|Version|Serial" || echo "Motherboard data restricted (sudo required)."
    sudo dmidecode -t bios 2>/dev/null | grep -E "Vendor|Version|Release" || echo "BIOS data restricted."
    echo ""
}

disk_det() {
    echo -e "\n*************** DISK *************** \n"
    lsblk -p -o NAME,FSTYPE,SIZE,MOUNTPOINT,UUID,MODEL,SERIAL
    echo -e "\nDisk Usage and Inodes:"
    df -Th
    echo ""
}

usb_det() {
    echo -e "\n*************** USB *************** \n"
    lsusb
    echo ""
}

bios_det(){
    echo -e "\n*************** BIOS *************** \n"
    sudo dmidecode -t bios | grep -E "Vendor|Version|Release Date|Address|Runtime Size|ROM Size"
    sudo dmidecode -t bios | sed -n '/Characteristics:/,$p' | grep -v "Characteristics:" | sed 's/^[ \t]*//'
}
battery_det(){
    echo -e "\n*************** BATTERY *************** \n"
    sudo dmidecode -t 22 | grep -E "Manufacturer|Name:|Design Capacity|Design Voltage|SBDS Serial Number|SBDS Chemistry" | sed 's/^[ \t]*//'
    echo -e "\n"
}
displayhard() {
    echo "-------------------------------------"
    echo "      DETAILED HARDWARE REPORT       "
    echo "-------------------------------------"

    cpu_det
    gpu_det
    ram_det
    mother_det
    disk_det
    network_det
    usb_det
    bios_det
    battery_det
    echo -e " ********* END OF REPORT ********* \n"
}

#################################################################################""
#SOFT PART

function os(){

    echo -e "********** OS INFORMATION **********"
    grep "^NAME=" /etc/os-release | tr -d '"' 
    grep "^VERSION=" /etc/os-release
    echo "KERNEL VERSION="$(uname -r)
    echo "System Architecture : "$(uname -m)
    echo "Desktop : $XDG_SESSION_DESKTOP"
}

function pro(){

    echo "********** INSTALLED PROGRAMMES **********"
    echo "Number of installed packages : "$(dpkg -l | wc -l)
    echo "Number of manual installed packages : "$(apt-mark showmanual | wc -l)
    echo 
    echo "Installed Programmes :"
    echo
    dpkg -l | awk '{print $2}' | paste -sd ', '
    echo
    echo "Manual installed programmes :"
    apt-mark showmanual | paste -sd ', '
}

function user(){

    echo -e "********** USER INFORMATION **********"
    echo "Current user: "$(whoami)
    echo "UID : "$(id -u)
    echo "GID : "$(id -g)
    echo "Groups : "$(groups)
    echo "Number of Groups :"$(groups | wc -w)
    echo "GIDs :"$(id -G)
    echo "Logged-in users:"
    who
    echo "Number of All system users:" $(cut -d: -f1 /etc/passwd | wc -l)
    echo " All system users:" $(cut -d: -f1 /etc/passwd | paste -sd ', ')
    
}

function sepr(){
    echo -e "********** SERVECIES AND PROCESSES **********"
    echo "   ---- Services ----"
    echo "Number Of All Services : "$(systemctl list-units --type=service | wc -l)
    echo "Number of Active Services : "$(systemctl list-units --type=service --state=running | wc -l)
    echo "Most Important Services : "
    systemctl status  bluetooth.service  accounts-daemon.service cups.service --no-pager
    echo
    echo "   ---- Processes ----"
    echo "Number of Processes : "$(ps aux | wc -l)
    echo "All Processes :"
    ps aux
}

function op(){
    echo -e "********** OPEN PORT **********"
    ss -tuln 
}

function displaysoft(){
    echo "-------------------------------------"
    echo "      DETAILED SOFTWARE REPORT       "
    echo "-------------------------------------"


    echo "HOSTNAME:"$(hostname)
    echo "DATE:"$(date)
    os
    echo
    pro 
    echo
    user
    echo
    sepr
    echo
    op
}

#display
displaysoft
displayhard 

#send through mail
echo -e "\nDo you want to send this report via email? (y/n)"
read answer
if [ "$answer" = "y" ]; then
    report_file="/var/log/sys_audit/full_report_$(date +%Y%m%d).txt"
    displaysoft > "$report_file"
    displayhard >> "$report_file"
    bash "$(dirname "$0")/mail.sh" "$report_file"

fi


