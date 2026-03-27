#!/bin/bash

report=$1

echo "Enter your email address :"
read EMAIL

cat $report | msmtp $EMAIL 
