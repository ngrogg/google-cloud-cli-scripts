#!/usr/bin/bash

# Snapshot
# BASH script for creating standard and archive snapshots using the Google Cloud SDK
# By Nicholas Grogg
# Revision: 20260727

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
    "standard/Standard" \
    "* Creates a standard snapshot" \
    "* Takes a hostname, purpose, intials and project as arguments" \
    "Usage, snapshot hostname purpose initials project" \
    "Ex. snapshot standard serverName wp ngg myProject" \
    " " \
    "archive/Archive" \
    "Creates an archive snapshot" \
    "Takes a hostname, purpose, and project as arguments" \
    "Usage, snapshots hostname purpose project" \
    "Ex. snapshot archive serverName storage myProject" \
    " "
}

# Helper Function to fetch instance zone and disk name
getServerInfo() {
    printf "%s\n" \
    "Getting server zone and disk name" \
    "----------------------------------------------------"

    ## Local variables for passed values
    local server="$1"
    local project="$2"

    ## Find server zone and disk
    serverZone=$(gcloud compute instances list --project="$project" \
        --filter="name=$server" \
        --format="value(zone.basename())" | head -n 1)

    diskName=$(gcloud compute disks list --project="$project" \
        --filter="name~$server" \
        --format="value(name)" | head -n 1)

    ## If values are null exit with error
    if [[ -z "$serverZone" || -z "$diskName" ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Could not find server or disk!" \
        "----------------------------------------------------" \
        "Double check values and re-run script.${normal}"
        exit 1
    fi
}

# Helper function to validate snapshots
validateSnapshot() {
    printf "%s\n" \
    "Snapshot Validation" \
    "----------------------------------------------------"

    ## Local variables for passed values
    local snapshotName="$1"
    local project="$2"
    local snapshotSize

    ## Find snapshot size
    snapshot_size=$(gcloud compute snapshots describe "$snapshotName" \
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
function createStandard(){
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
        helpFunction
        exit 1
    fi

    ## Retrieve zone & disk before asking for confirmation
    getServerInfo "$server" "$project"

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

    read junkInput

    ## Create snapshot
    ### Set snapshot name
    local snapshotName="${initials}-${diskName}-${purpose}-$(date +"%Y%m%d")"

    ### Take snapshot
    gcloud compute disks snapshot "$diskName" \
        --snapshot-names="$snapshotName" \
        --storage-location="us" \
        --zone="$serverZone" \
        --project="$project"

    ### Was snapshot taken successfully?
    if [[ $? = 0 ]]; then
        printf "%s\n" \
        "${green}Snapshot taken" \
        "----------------------------------------------------" \
        "Proceeding to validation ${normal}"

        validateSnapshot "$snapshotName" "$project"
    else
        printf "%s\n" \
        "${red}ISSUE DETECTED - Something went wrong!" \
        "----------------------------------------------------" \
        "Exiting! ${normal}"
        exit 1
    fi
}

# Function to create an archive snapshot
function createArchive(){
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
        helpFunction
        exit 1
    fi

    ## Retrieve zone & disk info
    getServerInfo "$server" "$project"

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
    read junkInput

    ## Is the server powered off?
    status=$(gcloud compute instances describe "$server" --project="$project" --zone="$serverZone" --format="value(status)" 2>/dev/null)

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
    local snapshotName="${shortname}-${diskName}-${purpose}-$(date +"%Y%m%d")"

    ### Take snapshot
    gcloud compute snapshots create "$snapshotName" \
        --source-disk="$diskName" \
        --storage-location="us" \
        --source-disk-zone="$serverZone" \
        --project="$project" \
        --snapshot-type="ARCHIVE" \
        --labels="auth-to-delete=no,customer=$shortname"

    ### Was snapshot taken successfully?
    if [[ $? = 0 ]]; then
        printf "%s\n" \
        "${green}Snapshot taken " \
        "----------------------------------------------------" \
        "Moving to validation ${normal}"

        validateSnapshot "$snapshotName" "$project"

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
    helpFunction
    exit
    ;;
[Ss]tandard)
    printf "%s\n" \
    "Standard snapshot flag passed" \
    "----------------------------------------------------"
    createStandard $2 $3 $4 $5
    ;;
[Aa]rchive)
    printf "%s\n" \
    "Archive snapshot flag passed" \
    "----------------------------------------------------"
    createArchive $2 $3 $4 $5
    ;;
*)
    printf "%s\n" \
    "${red}ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help function and exiting." \
    "Re-run script with valid input${normal}"
    helpFunction
    exit 1
    ;;
esac
