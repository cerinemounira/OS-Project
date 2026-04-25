#!/bin/bash

echo -e "\n NSCS OS S2 PROJECT \n"
echo -e "\n BY: MEGHRICI ROUKAYA && AOUANE MOUNIRA CERINE \n"
echo -e "\n SELECT A CHOICE FOR A HARDWARE AND SOFTWARE REPORT \n"
echo -e " 1. FULL REPORT & send to your email "
echo -e " 2. SMALL REPORT & send to your email "
echo -e " 3. BOTH & send to your email or via ssh"
echo -e "\n **** PLEASE ENTER YOUR CHOICE **** \n"

read choice

#check if input is empty
if [ -z "$choice" ]; then
    echo -e "\n[ERROR] No input provided. Please run the script again."
    exit 1
fi

if [ "$choice" -eq 1 ]; then
    echo -e "\n Full Report..."
    ./full.sh

elif [ "$choice" -eq 2 ]; then
    echo -e "\n Small Report..."
    ./summary.sh

elif [ "$choice" -eq 3 ]; then
    echo -e "\n[+] Both Reports..."
    ./full.sh
    ./summary.sh
    #send through ssh
echo -e "\nDo you want to send both reports via ssh? (y/n)"
read answer
if [ "$answer" = "y" ]; then
    bash "$(dirname "$0")/ssh.sh" 

fi

else 
    echo -e "\n[!] INVALID CHOICE! Please run the script again." 
fi


