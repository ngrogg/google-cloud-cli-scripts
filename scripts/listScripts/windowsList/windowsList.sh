#!/usr/bin/bash

# Windows List
# BASH script for listing Windows servers in GCP
# By Nicholas Grogg

# Set exit on error
set -e

# Color variables
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
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
    "display/Display " \
    "* Show all Windows servers in all projects" \
    "Ex. ./windowsList.sh display" \
    " " \
    "list/List" \
    "* Windows List" \
    "* Adjust regex as needed to filter/include servers" \
    "* List Windows servers in GCP" \
    "* No arguments, just run the script" \
    "* Saves output to CSV file " \
    "Ex. ./windowsList.sh list"
}

# Function to display all Windows servers across all projects
function displayServers(){
    printf "%s\n" \
    "Display" \
    "----------------------------------------------------"

    #TODO: Update projects to filter out as needed
    ## Array of projects
    projectArray=(`gcloud projects list | grep -E -v 'PROJECT_ID|^sys-[0123456789]|test|temp' | awk '{print $1}'`)

    ## Iterate through projects
    for project in "${projectArray[@]}"; do
        echo "${project}"
        gcloud compute instances list --project="${project}" --format="table(name,networkInterfaces[].networkIP,disks[].licenses)" --filter="disks[].licenses:(windows)"
    done
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "List" \
    "----------------------------------------------------"

    #TODO: Update projects to filter out as needed
    ## Array of projects
    projectArray=(`gcloud projects list | grep -E -v 'PROJECT_ID|^sys-[0123456789]|test|temp' | awk '{print $1}'`)

    ## Create/truncate csv file
    echo "Hostname,IP" > windowsList.csv

    ## Iterate through projects
    for project in "${projectArray[@]}"; do
        #TODO: For newer versions of Windows (i.e. 2022) add to the first grep -E filter and remove from the second grep -E filter
        ### List disks with Windows property, filter out newer 2019, 2022 disks
        ### Google doesn't update license for in-place upgrades and lists server as running old OS despite being upgraded
        ### Append to csv file
        gcloud compute instances list --project="${project}" --format="table(name,networkInterfaces[].networkIP,disks[].licenses)" --filter="disks[].licenses:(windows)" | grep -E "2012|2016" | grep -v -E "balanced|2019|2022|2025" | awk '{print $1 "," $2}' >> windowsList.csv
    done

    ## Edit csv file to remove quotes and brackets
    sed -i 's/\[//g' windowsList.csv
    sed -i 's/\]//g' windowsList.csv
    sed -i "s/'//g" windowsList.csv

    ## Back up windowsList.csv
    cp windowsList.csv outputFiles/windowsList_$(date +%Y%m%d%H%M).csv
}

# Main, read passed flags
printf "%s\n" \
"Windows List" \
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
[Ll]ist)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    runProgram
    ;;
[Dd]isplay)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    displayServers
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
