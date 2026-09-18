#!/usr/bin/env bash

# Project List
# BASH script to list all servers in a project
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
    "* List the servers in a project" \
    "* A server can also be passed with the project name" \
    "* If multiple projects match name, they will all be searched" \
    "Usage. ./project-list.sh list project hostname " \
    "Ex. ./project-list.sh list my_project webServer1"
}

# Function to run program
function run_program(){
    printf "%s\n" \
    "List" \
    "----------------------------------------------------"

    ## Variables
    ### Name of project to search
    project_name=$1
    ### Name of server to search for, can be blank
    server_name=$2
    ### Are there multiple matches? False by default.
    multi_match=0

    ## Validation
    ### If no value passed
    if [[ -z $project_name ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Invalid input detected!" \
        "----------------------------------------------------" \
        "Listing projects and exiting." \
        "Re-run script with valid input${normal}"
        gcloud projects list
        exit 1
    fi

    ## If more than one project matches on a partial project name
    if [[ $(gcloud projects list | grep $project_name | awk '{print $1}' | wc -l) -gt 1 ]]; then
        ### Set multi_match variable to true
        multi_match=1
        ### Populate array with project matches
        project_array=($(gcloud projects list | grep $project_name | awk '{print $1}'))
    fi

    ## If multi_match true, list all servers in matching projects
    if [[ $multi_match -eq 1 ]]; then
        for projectIt in "${project_array[@]}"
        do
            printf "%s\n" \
            "Project: " "$projectIt"

            ### if server_name variable null, just list project
            if [[ -z $server_name ]]; then
                gcloud compute instances list --project $projectIt
            ### Else grep for server_name
            else
                gcloud compute instances list --project $projectIt | grep $server_name
            fi
        done
    ## Else multi_match false just list project
    else
        ### Extra check for partial matches
        project_name=$(gcloud projects list | grep $project_name | awk '{print $1}' | head -n 1)

        printf "%s\n" \
        "Project: " "$project_name"

        ### if server_name variable null, just list project
        if [[ -z $server_name ]]; then
            gcloud compute instances list --project $project_name
        ### Else grep for server_name
        else
            gcloud compute instances list --project $project_name | grep $server_name
        fi
    fi
}

# Main, read passed flags
printf "%s\n" \
"Project List" \
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
    run_program $2 $3
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
