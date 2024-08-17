#!/usr/bin/bash

# CentOS List
# BASH script for listing CentOS servers in GCP
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
	"* CentOS List " \
	"* List CentOS servers in GCP " \
	"* No arguments, just run the script " \
	"Ex. ./centosList.sh list"
}

# Function to run program
function runProgram(){
	printf "%s\n" \
	"List" \
	"----------------------------------------------------"

    ## Array of projects, append project names/IDs to exclude as needed for your own uses
    projectArray=(`gcloud projects list | grep -E -v 'test|PROJECT|temp' | awk '{print $1}'`)

    ## Create/truncate csv file
    echo "Hostname,IP" > centosList.csv

    ## Iterate through projects
    for project in "${projectArray[@]}"
    do

            ### List disks with CentOS property, filter out 16/18/20 disks
            gcloud compute instances list --project="${project}" --format="table(name,networkInterfaces[].networkIP,disks[].licenses)" --filter="disks[].licenses:(centos)" | grep "centos-7" | grep -v "balanced" | awk '{print $1 "," $2}' >> centosList.csv
    done

    # Uncomment if you have specific server naming conventions for different server types and need that granularity
    ### Create spreadsheets for server types by picking them out of the master list
    #for i in TYPE TYPE TYPE; do
    #        ### Create/truncate csv file
    #        echo "Hostname,IP" > centosList-$i.csv

    #        ### Append list of servers
    #        grep $i centosList.csv >> centosList-$i.csv
    #done

}

# Main, read passed flags
	printf "%s\n" \
	"CentOS List" \
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
