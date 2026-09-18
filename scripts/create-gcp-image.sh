#!/usr/bin/env bash

# Create GCP Image
# BASH script to create an image from a GCP disk
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
    "create/Create" \
    "* Create Image from a GCP disk " \
    "* Takes an image name, disk name, zone and project as arguments " \
    "* Server should be powered off to create image" \
    "Ex. ./create-gcp-image.sh create IMAGE_NAME DISK_NAME ZONE PROJECT"
}

# Function to run program
function run_program(){
    printf "%s\n" \
    "Create" \
    "----------------------------------------------------"

    ## Validation
    ### Values to variables
    image_name=$1
    source_disk=$2
    source_zone=$3
    project_name=$4

    ### Does project exist?
    printf "%s\n" \
    "Validation: Does project exist?" \
    "----------------------------------------------------"

    ### If project exists
    if [[ $(gcloud projects list | grep $project_name) ]]; then
        printf "%s\n" \
        "${green}Project exists"\
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    ### Else exit with error
    else
        printf "%s\n" \
        "${red}ISSUE DETECTED - Project not found!"\
        "----------------------------------------------------" \
        "Double check values and re-run script${normal}"
        exit 1
    fi

    ### Does disk exist in project?
    printf "%s\n" \
    "Validation: Does disk exist in project?" \
    "----------------------------------------------------"

    ### If disk exists
    if [[ $(gcloud compute disks list --project $project_name | grep $source_disk) ]]; then
        printf "%s\n" \
        "${green}Disk exists"\
        "----------------------------------------------------" \
        "Proceeding${normal}" \
        " "
    ### Else exit with error
    else
        printf "%s\n" \
        "${red}ISSUE DETECTED - Disk not found! "\
        "----------------------------------------------------" \
        "Double check values and re-run script${normal}"
        exit 1
    fi

    ## Value Confirmation
    printf "%s\n" \
    "${yellow}IMPORTANT: Value Confirmation" \
    "----------------------------------------------------" \
    "Image to create: " "$image_name" \
    "" \
    "Source Disk: " "$source_disk" \
    "" \
    "Source Disk Zone: " "$source_zone" \
    "" \
    "Project: " "$project_name" \
    "" \
    "Server should be powered off before creating image" \
    "Script will fail if server is powered on" \
    "" \
    "If all clear, press enter to proceed or ctrl-c to cancel${normal}" \
    ""

    ### Last chance to bail
    read junk_input

    ## Create image
    gcloud compute images create $image_name --source-disk $source_disk --source-disk-zone $source_zone --project $project_name
}

# Main, read passed flags
    printf "%s\n" \
    "Create GCP Image" \
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
[Cc]reate)
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
