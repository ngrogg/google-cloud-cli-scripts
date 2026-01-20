#!/usr/bin/bash

# Cloud SSH
# BASH script for connecting to Linux servers via Google Cloud SDK
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
    "connect/Connect" \
    "* Connect to server" \
    "* Takes a hostname, zone, and project as arguments" \
    "Usage. ./cloudssh connect myServer us-west1-a myProject" \
    " " \
    "* Script also takes SSH keys as an optional argument " \
    "Usage. ./cloudssh connect myServer us-west1-a myProject ~/.ssh/id_ed25519"
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Connect" \
    "----------------------------------------------------"

    ## Variables
    serverName=$1
    serverZone=$2
    serverProject=$3
    sshKeyFilepath=$4

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

    # If no SSH sshKeyFilepath provided
    if [[ -z $sshKeyFilepath ]]; then
        gcloud compute ssh $serverName --zone $serverZone --project $serverProject --tunnel-through-iap
    else
        gcloud compute ssh $serverName --zone $serverZone --project $serverProject --ssh-key-file $sshKeyFilepath --tunnel-through-iap
    fi
}

# Main, read passed flags
printf "%s\n" \
"Cloud SSH" \
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
[Cc]onnect)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    runProgram $2 $3 $4 $5
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
