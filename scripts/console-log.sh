#!/usr/bin/env bash

# Console log
# Output Google Cloud Console log output
# By Nicholas Grogg
# Revision: 20260918

# Set exit on error
set -e

# Help function
function help_function(){
    printf "%s\n" \
    "Help" \
    "----------------------------------------------------" \
    " " \
    "help/Help" \
    "* Display this help message and exit" \
    " " \
    "log/Log" \
    "* Outputs Google Cloud Console logs for server " \
    "* Takes hostname zone and project as arguments " \
    "Ex. ./console-log.sh log hostname zone project"
}

# Function to run program
function run_program(){
    printf "%s\n" \
    "Console log" \
    "----------------------------------------------------"

    ## Assign passed flags to variables
    hostname=$1
    zone=$2
    project=$3

    ## Validation
    if [[ -z $hostname ]]; then
        printf "%s\n" \
        "ISSUE DETECTED: Hostname value empty" \
        "----------------------------------------------------" \
        "Enter a hostname"
        read hostname
    fi

    if [[ -z $zone ]]; then
        printf "%s\n" \
        "ISSUE DETECTED: Zone value empty" \
        "----------------------------------------------------" \
        "Enter a zone"
        read zone
    fi

    if [[ -z $project ]]; then
        printf "%s\n" \
        "ISSUE DETECTED: Project value empty" \
        "----------------------------------------------------" \
        "Enter a project"
        read project
    fi

    ## Output console log
    gcloud compute instances tail-serial-port-output $hostname --zone $zone --project $project
}

# Main, read passed flags
printf "%s\n" \
"Console log" \
"----------------------------------------------------" \
" " \
"Checking flags passed" \
"----------------------------------------------------"

# Check passed flags
case "$1" in
[Hh]elp)
    printf "%s\n" \
    "Running Help function" \
    "----------------------------------------------------"
    help_function
    exit
    ;;
[Ll]og)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    run_program $2 $3 $4
    ;;
*)
    printf "%s\n" \
    "ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input"
    help_function
    exit
    ;;
esac
