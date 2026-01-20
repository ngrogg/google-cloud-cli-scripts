#!/usr/bin/bash

# GCP Restart
# BASH script to restart server with Google Cloud SDK
# By Nicholas Grogg
# Revision: 20260119

# Color variables
## Errors
red=$(tput setaf 1)
## Clear checks
green=$(tput setaf 2)
## User input required
yellow=$(tput setaf 3)
## Set text back to standard terminal font
normal=$(tput sgr0)


# Help function
function helpFunction(){
    printf "%s\n" \
    "Help" \
    "----------------------------------------------------" \
    " " \
    "help/Help" \
    "* Display this help message and exit" \
    " " \
    "restart/Restart" \
    "* Restart a server" \
    "* Takes a hostname, zone and project as arguments" \
    "Usage. ./gcpRestart restart myServer us-west1-b myProject"
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Restart" \
    "----------------------------------------------------"

    ## Variables
    serverName=$1
    serverZone=$2
    serverProject=$3

    ## Validation
    if [[ -z $serverName ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Invalid input detected!" \
        "----------------------------------------------------" \
        "Running help script and exiting." \
        "Re-run script with valid input${normal}"
        helpFunction
        exit 1
    fi

    ## Stop/start server
    gcloud compute instances stop $serverName --zone $serverZone --project $serverProject
    gcloud compute instances start $serverName --zone $serverZone --project $serverProject
}

# Main, read passed flags
printf "%s\n" \
"GCP Restart" \
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
    helpFunction
    exit
    ;;
[Rr]estart)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    runProgram $2 $3 $4
    ;;
*)
    printf "%s\n" \
    "${red}ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input${normal}"
    helpFunction
    exit
    ;;
esac
