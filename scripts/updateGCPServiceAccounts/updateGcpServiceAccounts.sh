#!/usr/bin/env bash

# Update GCP Service Accounts
# Updates GCP service accounts for instances in an input file
# By Nicholas Grogg
# Revision: 20260728

# Set exit on error
set -e
# Uncomment for error on unset variables
# set -u
# Uncomment for exit on non-zero status from rightmost pipe command
set -o pipefail

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
    "run/Run" \
    "* Updates GCP service account for instances in an input file " \
    "* Usage: ./updateGcpServiceAccounts.sh run /path/to/inputFile.txt" \
    " "
}

# Function to run program
function runProgram(){
    local input_file="$1"

    if [[ -z "$input_file" ]]; then
        printf "%s\n"
        "----------------------------------------------------" \
        "${red}Error: Missing input file argument.${normal}"
        helpFunction
        exit 1
    fi

    if [[ ! -f "$input_file" ]]; then
        printf "%s\n"
        "----------------------------------------------------" \
        "${red}Error: File '$input_file' not found.${normal}"
        exit 1
    fi

    ## Value confirmation
    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Servers to reboot and their projects/zones:" \
    " "
    cat server.txt

    printf "%s\n" \
    " " \
    "File contents NEED to be in the following order:" \
    "HOSTNAME PROJECT ZONE" \
    " " \
    "If all clear, press enter to proceed or ctrl-c to cancel${normal}" \
    " "

    read junkInput

    printf "%s\n" \
    "Run" \
    "----------------------------------------------------" \
    "Starting server maintenance process" \
    " "

    # Read input file line by line
    while read -r HOSTNAME PROJECT ZONE || [ -n "$HOSTNAME" ]; do
        # Skip empty lines and comments starting with #
        [[ -z "$HOSTNAME" || "$HOSTNAME" =~ ^[[:space:]]*# ]] && continue

        # Validate line format
        if [[ -z "$PROJECT" ]] || [[ -z "$ZONE" ]]; then
            printf "%s\n"
            "${yellow}Skipping malformed line: '$HOSTNAME $PROJECT $ZONE'${normal}"
            continue
        fi

        printf "%s\n" \
        "Processing" \
        "----------------------------------------------------" \
        "Processing: $HOSTNAME" \
        "Project:    $PROJECT" \
        "Zone:       $ZONE" \
        " "

        # 1. Power off the server
        printf "%s\n" \
        "Powering off server" \
        "----------------------------------------------------" \
        " "

        # If server is already stopped, stopping it might throw an error. We can catch it without failing the whole script
        gcloud compute instances stop "$HOSTNAME" \
            --project="$PROJECT" \
            --zone="$ZONE" \
            --quiet || printf "%s\n" "${yellow}Warning: Failed to stop instance or already stopped.${normal}"

        # 2. Get the default Compute Engine service account for the project
        printf "%s\n" \
        "Finding default Service Account" \
        "----------------------------------------------------" \
        " "

        # TODO: Configure Account and scope as needed
        local PROJECT_NUMBER
        PROJECT_NUMBER=$(gcloud projects describe "$PROJECT" --format="value(projectNumber)")
        local DEFAULT_SA="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

        # 3. Attach default service account with default access scopes
        printf "%s\n" \
        "Attaching default Service Account" \
        "----------------------------------------------------" \
        " "

        gcloud compute instances set-service-account "$HOSTNAME" \
            --project="$PROJECT" \
            --zone="$ZONE" \
            --service-account="$DEFAULT_SA" \
            --scopes=default \
            --quiet

        # 4. Power the server back on
        printf "%s\n" \
        "Powering server back on" \
        "----------------------------------------------------" \
        " "

        gcloud compute instances start "$HOSTNAME" \
            --project="$PROJECT" \
            --zone="$ZONE" \
            --quiet

    done < "$input_file"

    printf "%s\n" \
    "${green}Script complete" \
    "----------------------------------------------------" \
    "All servers processed.${normal}" \
    " "
}

# Main, read passed flags
printf "%s\n" \
"Update GCP Service Accounts" \
"----------------------------------------------------" \
" " \
"Checking flags passed" \
"----------------------------------------------------" \
" "

# Check passed flags
if [[ $# -eq 0 ]]; then
    printf "%s\n" \
    "${red}ISSUE DETECTED - No arguments provided!${normal}" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    " "
    helpFunction
    exit 1
fi

case "$1" in
[Hh]elp)
    printf "%s\n" \
    "Running Help function" \
    "----------------------------------------------------" \
    " "

    helpFunction
    exit 0
    ;;
[Rr]un)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------" \
    " "

    runProgram "$2"
    ;;
*)
    printf "%s\n" \
    "${red}ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input${normal}" \
    " "

    helpFunction
    exit 1
    ;;
esac
