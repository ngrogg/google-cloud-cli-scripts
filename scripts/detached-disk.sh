#!/usr/bin/env bash

# Detached Disk
# BASH script to iterate through projects and list all disks that aren't attached to anything
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
    "list/List" \
    "* Detached Disks " \
    "* Lists disks that aren't attached to anything " \
    "* Just past the list argument " \
    " " \
    "Ex. ./detached_disk.sh list"
}

# Function to run program
function run_program(){
    printf "%s\n" \
    "List" \
    "----------------------------------------------------"

    printf "%s\n" \
    "Getting list of projects "\
    "----------------------------------------------------" \
    " "

    ## Array of projects, append project names/IDs to exclude as needed for your own uses
    project_array=(`gcloud projects list | grep -E -v 'test|PROJECT|temp' | awk '{print $1}'`)

    ## For loop to iterate through projects and output disks
    for project in "${project_array[@]}"
    do
        printf "%s\n" \
        "Project: " "$project" \
        "----------------------------------------------------" \
        " "

        ### List all disks in the project
        disks=$(gcloud compute disks list --project=$project --format="table[no-heading](name, zone, users)")

        ### Check if the disk is attached to any VM
        echo "$disks" | while read -r name zone users; do
            if [[ -z "$users" && ! -z "$name" ]]; then
                printf "%s\n" \
                "${yellow}Disk: " "$name" \
                "Zone: " "$zone${normal}" \
                " "
            fi
        done
  done
}

# Main, read passed flags
printf "%s\n" \
"Detached Disks" \
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
[Ll]ist)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    run_program
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
