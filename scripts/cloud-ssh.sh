#!/usr/bin/env bash

# Cloud SSH
# BASH script for connecting to Linux servers via Google Cloud SDK
# By Nicholas Grogg
# Revision: 20260918

# Set exit on error
set -e

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
function help_function(){
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
    "Usage. ./cloudssh connect my_server us-west1-a my_project" \
    " " \
    "* Script also takes SSH keys as an optional argument " \
    "Usage. ./cloudssh connect my_server us-west1-a my_project ~/.ssh/id_ed25519"
}

# Function to run program
function run_program(){
    printf "%s\n" \
    "Connect" \
    "----------------------------------------------------"

    ## Variables
    server_name=$1
    server_zone=$2
    server_project=$3
    ssh_key_filepath=$4

    ## Validation
    if [[ -z $server_name ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Invalid input detected!" \
        "----------------------------------------------------" \
        "Running help script and exiting." \
        "Re-run script with valid input${normal}"
        help_function
        exit 1
    fi

    # If no SSH ssh_key_filepath provided
    if [[ -z $ssh_key_filepath ]]; then
        gcloud compute ssh $server_name --zone $server_zone --project $server_project --tunnel-through-iap
    else
        gcloud compute ssh $server_name --zone $server_zone --project $server_project --ssh-key-file $ssh_key_filepath --tunnel-through-iap
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
    help_function
    exit
    ;;
[Cc]onnect)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    run_program $2 $3 $4 $5
    ;;
*)
    printf "%s\n" \
    "${red}ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input${normal}"
    help_function
    exit
    ;;
esac
