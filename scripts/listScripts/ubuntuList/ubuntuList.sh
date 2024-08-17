#!/usr/bin/bash

# Ubuntu List
# BASH script for listing Ubuntu servers in GCP
# By Nicholas Grogg

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
	"list/List" \
	"* Ubuntu List " \
	"* List Ubuntu servers in GCP " \
	"* No arguments, just run the script " \
	"Ex. ./ubuntuList.sh list"
}

# Function to run program
function runProgram(){
	printf "%s\n" \
	"List" \
	"----------------------------------------------------"

    ## Array of projects, append project names/IDs to exclude as needed for your own uses
    projectArray=(`gcloud projects list | grep -E -v 'test|PROJECT|temp' | awk '{print $1}'`)

    ## Create/truncate csv file
    echo "Hostname,IP" > ubuntuList.csv

    ## Iterate through projects
    for project in "${projectArray[@]}"
    do

            ### List disks with Ubuntu property, you may need to adjust the grep -E filter for your own needs
            gcloud compute instances list --project="${project}" --format="table(name,networkInterfaces[].networkIP,disks[].licenses)" --filter="disks[].licenses:(ubuntu)" | grep -E "ubuntu-16|ubuntu-18|ubuntu-20" | grep -v "balanced" | awk '{print $1 "," $2}' >> ubuntuList.csv
    done

}

# Main, read passed flags
	printf "%s\n" \
	"Ubuntu List" \
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
