#!/usr/bin/bash

# CloudSCP
# BASH script for moving local files to GCP server via Gcloud Compute
# By Nicholas Grogg
# Revision: 20251230

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
    "copy/Copy" \
    "* Copy local file to remote server" \
    "* Do not run as root or with sudo perms" \
    "* Uses local username on remote system" \
    "* Use private key for ssh key argument" \
    "Usage. ./cloudscp.sh copy /path/to/local/file SERVER ZONE PROJECT (optional) /path/to/sshkey"
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "Copy" \
    "----------------------------------------------------"

    ## Variables
    ### What to copy
    copyPath=$1
    ### Server hostname to copy to
    serverHost=$2
    ### Zone of server in GCP
    serverZone=$3
    ### Project of server in GCP
    serverProject=$4
    ### Optional path to SSH key
    sshKeyPath=$5
    ### Username running script (may need adjusted if local/remote usernames don't match)
    username=$(whoami)

    ## Validation
    ### Running as root?
    if [[ "$EUID" -eq 0 ]]; then
        printf "%s\n" \
        "${red}User is root or running as root" \
        "----------------------------------------------------" \
        "Script cannot be run with admin permissions!${normal}" \
        " " \
        "Running help function and exiting"

        helpFunction

        exit 1
    fi

    ## Copy
    ### If no SSH Key filepath provided
    if [[ -z $sshKeyPath ]]; then
        gcloud compute scp $copyPath $serverHost:/home/$username --zone $serverZone --project $serverProject --tunnel-through-iap
    ### Else use SSH key
    else
        gcloud compute scp $copyPath $serverHost:/home/$username --zone $serverZone --project $serverProject --ssh-key-file $sshKeyPath --tunnel-through-iap
    fi
}

# Main, read passed flags
printf "%s\n" \
"Cloud SCP" \
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
[Cc]opy)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    runProgram $2 $3 $4 $5 $6
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
