#!/usr/bin/env bash

# Snapshot Removal
# BASH script to remove GCP snapshots over a week old
# By Nicholas Grogg
# Revision: 20260918

# Set exit on error
set -e

## Help function
function help_function(){
    printf "%s\n" \
    "Help" \
    "----------------------------------------------------" \
    " " \
    "help/Help" \
    "* Display this help message and exit" \
    " " \
    "remove/Remove" \
    "* List and remove old snapshots" \
    "* Takes user initials as arguments" \
    "Ex. ./snapshot_removal remove ngg"
}

## Function to run program
function run_program(){
    printf "%s\n" \
    "Main" \
    "----------------------------------------------------"

    ### Assign passed initials to variable
    initials="$1"

    ### Date 1 week ago
    week_ago=`date --date="1 week ago" +%Y-%m-%d`

    ### Populate array with projects
    project_array=(`gcloud projects list | awk "{print $1}"`)

    ### Iterate through projects and remove snapshots
    for project in "${project_array[@]}"
    do
        echo "${project}: "
        #### If no snapshots that meet criteria found
        if [[ -z $(gcloud compute snapshots list --filter="creationTimestamp<"$week_ago"" --project "${project}" | grep "${initials}-") ]]; then
            echo "No snapshots meet criteria"

        #### Else populate array and remove resulting snapshots
        else
            ##### Populate Array with snapshots
            snapshot_array=(`gcloud compute snapshots list --filter="creationTimestamp<"$week_ago"" --project "${project}" | grep "${initials}-" | awk "{print $1}"`)
            ##### For loop to remove snapshots
            for snapshot in "${snapshot_array[@]}"
            do
                ###### Delete snapshot
                gcloud compute snapshots delete --project "${project}" $snapshot --quiet
            done
        fi

        #### Whitespace for readability
        echo ""
    done

}

## Main, read passed flags
printf "%s\n" \
"GCP Snapshot removal" \
"----------------------------------------------------" \
" " \
"Checking flags passed" \
"----------------------------------------------------"

## Check passed flags
case "$1" in
[Hh]elp)
    printf "%s\n" \
    "Running Help function" \
    "----------------------------------------------------"
    help_function
    exit
    ;;
[Rr]emove)
    printf "%s\n" \
    "Running script to remove snapshots" \
    "----------------------------------------------------"
    run_program $2
    ;;
*)
    printf "%s\n" \
    "ISSUE DETECTED - Invalid input detected!" \
    "----------------------------------------------------" \
    "Running help script and exiting." \
    "Re-run script with valid input"
    help_function
    exit
    ;;
esac
