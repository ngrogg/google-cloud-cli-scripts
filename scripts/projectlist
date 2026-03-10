#!/usr/bin/bash

# Project List
# BASH script to list all servers in a project
# By Nicholas Grogg
# Revision: 20260309

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
    "list/List" \
    "* List the servers in a project" \
    "* A server can also be passed with the project name" \
    "* If multiple projects match name, they will all be searched" \
    "Usage. ./projectlist list project hostname " \
    "Ex. ./projectlist list myProject webServer1"
}

# Function to run program
function runProgram(){
    printf "%s\n" \
    "List" \
    "----------------------------------------------------"

    ## Variables
    ### Name of project to search
    projectName=$1
    ### Name of server to search for, can be blank
    serverName=$2
    ### Are there multiple matches? False by default.
    multiMatch=0

    ## Validation
    ### If no value passed
    if [[ -z $projectName ]]; then
        printf "%s\n" \
        "${red}ISSUE DETECTED - Invalid input detected!" \
        "----------------------------------------------------" \
        "Listing projects and exiting." \
        "Re-run script with valid input${normal}"
        gcloud projects list
        exit 1
    fi

    ## If more than one project matches on a partial project name
    if [[ $(gcloud projects list | grep $projectName | awk '{print $1}' | wc -l) -gt 1 ]]; then
        ### Set multiMatch variable to true
        multiMatch=1
        ### Populate array with project matches
        projectArray=($(gcloud projects list | grep $projectName | awk '{print $1}'))
    fi

    ## If multiMatch true, list all servers in matching projects
    if [[ $multiMatch -eq 1 ]]; then
        for projectIt in "${projectArray[@]}"
        do
            printf "%s\n" \
            "Project: " "$projectIt"

            ### if serverName variable null, just list project
            if [[ -z $serverName ]]; then
                gcloud compute instances list --project $projectIt
            ### Else grep for serverName
            else
                gcloud compute instances list --project $projectIt | grep $serverName
            fi
        done
    ## Else multiMatch false just list project
    else
        ### Extra check for partial matches
        projectName=$(gcloud projects list | grep $projectName | awk '{print $1}' | head -n 1)

        printf "%s\n" \
        "Project: " "$projectName"

        ### if serverName variable null, just list project
        if [[ -z $serverName ]]; then
            gcloud compute instances list --project $projectName
        ### Else grep for serverName
        else
            gcloud compute instances list --project $projectName | grep $serverName
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
    helpFunction
    exit
    ;;
[Ll]ist)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------"
    runProgram $2 $3
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
