#!/usr/bin/env bash

# GCP Restart
# BASH script to restart server with Google Cloud SDK
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
    "restart/Restart" \
    "* Restart a server" \
    "* Takes a hostname, zone and project as arguments" \
    "Usage. ./gcp-restart.sh restart my_server us-west1-b my_project"
}

# Function to run program
function run_program(){
    printf "%s\n" \
    "Restart" \
    "----------------------------------------------------"

    ## Variables
    server_name=$1
    server_zone=$2
    server_project=$3

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

    ## Stop/start server
    gcloud compute instances stop $server_name --zone $server_zone --project $server_project
    gcloud compute instances start $server_name --zone $server_zone --project $server_project
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
    help_function
    exit
    ;;
[Rr]estart)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    run_program $2 $3 $4
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
