#!/usr/bin/env bash

# Snapshot
# BASH script for creating standard and archive snapshots using the Google Cloud SDK
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
    "standard/Standard" \
    "* Creates a standard snapshot" \
    "* Takes a hostname, purpose, intials and project as arguments" \
    "Usage, snapshot hostname purpose initials project" \
    "Ex. snapshot.sh standard server_name wp ngg my_project" \
    " " \
    "archive/Archive" \
    "Creates an archive snapshot" \
    "Takes a hostname, purpose, and project as arguments" \
    "Usage, snapshots hostname purpose project" \
    "Ex. snapshot.sh archive server_name storage my_project" \
    " "
}

# Helper Function to fetch instance zone and disk name
function get_server_info() {
    printf "%s\n" \
    "Getting server zone and disk name" \
    "----------------------------------------------------"

    ## Local variables for passed values
    local server="$1"
    local project="$2"

    ## Find server zone and disk
    server_zone=$(gcloud compute instances list --project="$project" \
        --filter="name=$server" \
        --format="value(zone.basename())" | head -n 1)

    diskName=$(gcloud compute disks list --project="$project" \
        --filter="name~$server" \
        --format="value(name)" | head -n 1)

    ## If values are null exit with error
    if [[ -z "$server_zone" || -z "$diskName" ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Could not find server or disk!" \
        "----------------------------------------------------" \
        "Double check values and re-run script.${normal}"
        exit 1
    fi
}

# Helper function to validate snapshots
function validate_snapshot() {
    printf "%s\n" \
    "Snapshot Validation" \
    "----------------------------------------------------"

    ## Local variables for passed values
    local snapshot_name="$1"
    local project="$2"
    local snapshot_size

    ## Find snapshot size
    snapshot_size=$(gcloud compute snapshots describe "$snapshot_name" \
        --project="$project" \
        --format="value(storageBytes)" 2>/dev/null)

    ## If gcloud command failed
    if [[ $? -ne 0 || -z "$snapshot_size" ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Gcloud command failed!"
        "----------------------------------------------------" \
        "Double check if snapshot exists" \
        " " \
        "Take snapshot manually if need be.${normal}" \
        " "

        exit 1
    fi

    ## If snapshot size is empty return error
    if [[ "$snapshot_size" -eq 0 ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Snapshot size is 0 B!"
        "----------------------------------------------------" \
        "Do not proceed!${normal}" \
        " "

        exit 1
    else
        printf "%s\n" \
        "${green}Snapshot size > 0 B " \
        "----------------------------------------------------" \
        "Proceed with work effort.${normal}"

        exit 0
    fi
}

# Function to create a standard snapshot
function create_standard(){
    printf "%s\n" \
    "Standard Snapshot" \
    "----------------------------------------------------"

    ## Store passed values
    local server="$1"
    local purpose="$2"
    local initials="$3"
    local project="$4"

    ## Variable validation
    if [[ -z "$server" ]] || [[ -z "$purpose" ]] || [[ -z "$initials" ]] || [[ -z "$project" ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Variable missing " \
        "----------------------------------------------------" \
        "Running help function and exiting." \
        "Re-run script with valid input${normal}"
        help_function
        exit 1
    fi

    ## Retrieve zone & disk before asking for confirmation
    get_server_info "$server" "$project"

    ## Confirmation
    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Snapshot Type: Standard" \
    "Server:        $server" \
    "Purpose:       $purpose" \
    "Sysadmin:      $initials" \
    "Project:       $project" \
    " " \
    "If all clear, press enter to proceed or ctrl-c to cancel${normal}"

    read junk_input

    ## Create snapshot
    ### Set snapshot name
    local snapshot_name="${initials}-${diskName}-${purpose}-$(date +"%Y%m%d")"

    ### Take snapshot
    gcloud compute disks snapshot "$diskName" \
        --snapshot-names="$snapshot_name" \
        --storage-location="us" \
        --zone="$server_zone" \
        --project="$project"

    ### Was snapshot taken successfully?
    if [[ $? = 0 ]]; then
        printf "%s\n" \
        "${green}Snapshot taken" \
        "----------------------------------------------------" \
        "Proceeding to validation ${normal}"

        validate_snapshot "$snapshot_name" "$project"
    else
        printf "%s\n" \
        "${red}ISSUE DETECTED - Something went wrong!" \
        "----------------------------------------------------" \
        "Exiting! ${normal}"
        exit 1
    fi
}

# Function to create an archive snapshot
function create_archive(){
    printf "%s\n" \
    "Archive Snapshot" \
    "----------------------------------------------------"

    ## Store passed values
    local server="$1"
    local purpose="$2"
    local project="$3"
    local shortname="$4"

    ## Variable validation
    if [[ -z "$server" ]] || [[ -z "$purpose" ]] || [[ -z "$project" ]] || [[ -z "$shortname" ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Variable missing " \
        "----------------------------------------------------" \
        "Running help function and exiting." \
        "Re-run script with valid input${normal}"
        help_function
        exit 1
    fi

    ## Retrieve zone & disk info
    get_server_info "$server" "$project"

    ## Confirmation
    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Snapshot Type: Archive" \
    "Server:        $server" \
    "Purpose:       $purpose" \
    "Project:       $project" \
    "Shortname:     $shortname" \
    "" \
    "Server needs to be powered off!" \
    "" \
    "If all clear, press enter to proceed or ctrl-c to cancel${normal}"
    read junk_input

    ## Is the server powered off?
    status=$(gcloud compute instances describe "$server" --project="$project" --zone="$server_zone" --format="value(status)" 2>/dev/null)

    if [[ "$status" != "TERMINATED" ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Server is not powered off!" \
        "----------------------------------------------------" \
        "Archive snapshots require the server powered off." \
        "Shut down the server and re-run the script." \
        " " \
        "Exiting!${normal}"

        exit 1
    else
        printf "%s\n" \
        "${green}Server powered off" \
        "----------------------------------------------------" \
        "Proceeding${normal}"
    fi

    ### Variable name for snapshot
    local snapshot_name="${shortname}-${diskName}-${purpose}-$(date +"%Y%m%d")"

    ### Take snapshot
    gcloud compute snapshots create "$snapshot_name" \
        --source-disk="$diskName" \
        --storage-location="us" \
        --source-disk-zone="$server_zone" \
        --project="$project" \
        --snapshot-type="ARCHIVE" \
        --labels="auth-to-delete=no,customer=$shortname"

    ### Was snapshot taken successfully?
    if [[ $? = 0 ]]; then
        printf "%s\n" \
        "${green}Snapshot taken " \
        "----------------------------------------------------" \
        "Moving to validation ${normal}"

        validate_snapshot "$snapshot_name" "$project"

    else
        printf "%s\n" \
        "${red}ISSUE DETECTED - Something went wrong!" \
        "----------------------------------------------------" \
        "Exiting! ${normal}"
        exit 1
    fi
}

# Main, read passed flags
printf "%s\n" \
"Snapshot" \
"----------------------------------------------------" \
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
[Ss]tandard)
    printf "%s\n" \
    "Standard snapshot flag passed" \
    "----------------------------------------------------"
    create_standard $2 $3 $4 $5
    ;;
[Aa]rchive)
    printf "%s\n" \
    "Archive snapshot flag passed" \
    "----------------------------------------------------"
    create_archive $2 $3 $4 $5
    ;;
*)
    printf "%s\n" \
    "${red}ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help function and exiting." \
    "Re-run script with valid input${normal}"
    help_function
    exit 1
    ;;
esac
