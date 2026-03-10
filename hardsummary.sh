#!/bin/bash

function cpu(){
    echo -e "\n*************** CPU *************** \n"
    lscpu | grep -E "Model name|Architecture"
    lscpu | grep -E '^Thread|^Core|^Socket|^CPU\(' | head -n3
}

function gpu(){
    echo -e "\n*************** GPU *************** \n"
    glxinfo | grep "Device"
    ##lspci | grep -i vga
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
    echo -e "\n*************** BIOS *************** \n"
    sudo dmidecode -t 22 | grep -E "Location|Manufacturer|Name|Desig|Chemistry"
}

function display(){
    echo -e "\n ********* HARDWARE RAPORT SMALL ********* \n"
    echo -e "HOSTNAME: $(hostname)"
    date
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

display

