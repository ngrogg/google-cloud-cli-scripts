#!/usr/bin/env bash

# Database Tech List
# BASH script to find Linux servers running Database tech and version
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
    "populate/Populate " \
    "* Populate files used by list function " \
    "Usage. ./database-tech-list.sh populate " \
    " " \
    "list/List" \
    "* Create CSV file of database tech and versions" \
    "* Takes database tech and version as arguments " \
    "* Mysql, MariaDB, Postgres or Psql acceptable" \
    "Ex. ./database-tech-list.sh list MariaDB 10.6"
}

# Function to populate teriary files
function populate_lists(){
    ## Truncate output files
    echo "" > tertiary_files/all_list.txt
    echo "" > tertiary_files/all_list_sorted.txt
    echo "" > tertiary_files/serverList.txt
    echo "" > tertiary_files/windowsList.txt
    echo "" > tertiary_files/windowsListSorted.txt

    printf "%s\n" \
    "Getting list of projects "\
    "----------------------------------------------------" \
    " "

    ## Array of projects, append project names/IDs to exclude as needed for your own uses
    project_array=(`gcloud projects list | grep -E -v 'test|PROJECT|temp' | awk '{print $1}'`)


    printf "%s\n" \
    "Getting list of servers"\
    "----------------------------------------------------" \
    " "

    ## For loop to iterate through projects and populate output file with  servers
    for project in "${project_array[@]}"
    do
        ### Find Windows servers specifically, you may need to adjust this based on your own needs.
        gcloud compute instances list --project="${project}" --format="table(name,zone,disks[].licenses)" | grep -i windows | awk '{print $1}' >> tertiary_files/windowsList.txt

        ### Find powered on servers. Write hostnames to server list file. You may need to adjust this based on your own needs.
        gcloud compute instances list --project="${project}" | grep -E -v 'TERMINATED' | awk '{print $1}' >> tertiary_files/all_list.txt

    done

    ## Sort files
    sort tertiary_files/windowsList.txt -o tertiary_files/windowsListSorted.txt
    sort tertiary_files/all_list.txt -o tertiary_files/all_list_sorted.txt

    ## Pick out items unique to all_list_sorted.txt and write to serverList, should filter out Windows
    comm -13 tertiary_files/windowsListSorted.txt tertiary_files/all_list_sorted.txt >> tertiary_files/serverList.txt

}

# Function to run program
function run_program(){
    printf "%s\n" \
    "List" \
    "----------------------------------------------------" \
    " "

    ## Variables
    database_tech=$1
    tech_version=$2

    ## Validation
    ### Case Statement based on database tech
    printf "%s\n" \
    "Checking database tech passed "\
    "----------------------------------------------------" \
    " "

    case "$database_tech" in
        ### Postgres
        [Pp][Ss][Qq][Ll]|[Pp][Oo][Ss][Tt][Gg][Rr][Ee][Ss])
            # Truncate output files
            echo "Hostname,Psql Version" > database_tech_version.csv
            tech_shortname="psql"
            ;;
        ### MySQL
        [Mm][Yy][Ss][Qq][Ll])
            # Truncate output files
            echo "Hostname,MySQL Version" > database_tech_version.csv
            tech_shortname="mysql"
            ;;
        ### MariaDB
        [Mm][Aa][Rr][Ii][Aa][Dd][Bb])
            # Truncate output files
            echo "Hostname,MariaDB Version" > database_tech_version.csv
            tech_shortname="mariadb"
            ;;
        ### Fail state
        *)
            printf "%s\n" \
            "${red}ISSUE DETECTED - Invalid input detected!" \
            "----------------------------------------------------" \
            "Running help script and exiting." \
            "Re-run script with valid input${normal}"
            help_function
            exit 1
            ;;
    esac

    ### Check if tech_version empty
    printf "%s\n" \
    "Checking database version passed "\
    "----------------------------------------------------" \
    " "

    if [[ -z $tech_version ]]; then
        while [[ -z $tech_version ]]; do
            printf "%s\n" \
            "${yellow}IMPORTANT: Enter a value for Database version" \
            "----------------------------------------------------" \
            "Example Versions: '10', '8.1' ${normal}" \
            " "

            read tech_version
        done
    fi

    printf "%s\n" \
    "Populating CSV output file "\
    "----------------------------------------------------" \
    " "

    ## For loop to pick out servers running passed value version of MariaDB
    for i in $(cat tertiary_files/serverList.txt)
    do
        ## Get database tech version
        if [[ "$tech_shortname" == "psql" ]]; then
            database_tech_version=$(ssh $i "$tech_shortname -V" | awk '{print $3}')
        elif [[ "$tech_shortname" == "mysql" ]]; then
            database_tech_version=$(ssh $i "$tech_shortname -V" | awk '{print $3}')
        elif [[ "$tech_shortname" == "mariadb" ]]; then
            database_tech_version=$(ssh $i "$tech_shortname -V" | awk '{print $5}' | rev | cut -c2- | rev)
        else
            printf "%s\n" \
            "${red}ISSUE DETECTED - Invalid input detected!" \
            "----------------------------------------------------" \
            "Running help script and exiting." \
            "Re-run script with valid input${normal}"
            help_function
            exit
        fi

        ## If database_tech_version version matches, append to database_tech_version spreadsheet
        if [[ "$database_tech_version" == "$tech_version"* ]]; then
            echo "$i,$database_tech_version" >> database_tech_version.csv
        fi
    done

    ## Keep copy of CSV file
    cp database_tech_version.csv outputFiles/database_tech_version.csv.$(date +%Y%m%d%H%M)
}

# Main, read passed flags
printf "%s\n" \
"Database Tech List" \
"----------------------------------------------------" \
" " \
"Checking flags passed" \
"----------------------------------------------------" \
" "

# Check passed flags
case "$1" in
[Hh]elp)
    printf "%s\n" \
    "Running Help function" \
    "----------------------------------------------------" \
    " "

    help_function
    exit
    ;;
[Ll]ist)
    printf "%s\n" \
    "Running script" \
    "----------------------------------------------------" \
    " "

    run_program $2 $3
    ;;
[Pp]opulate)
    printf "%s\n" \
    "Populating lists" \
    "----------------------------------------------------" \
    " "

    populate_lists
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
