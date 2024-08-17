#!/usr/bin/bash

# Database Tech List
# BASH script to find Linux servers running Database tech and version
# By Nicholas Grogg

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
	"populate/Populate " \
	"* Populate files used by list function " \
	"Usage. ./databaseTechList.sh populate " \
	" " \
	"list/List" \
	"* Create CSV file of database tech and versions" \
	"* Takes database tech and version as arguments " \
    "* Mysql, MariaDB, Postgres or Psql acceptable" \
	"Ex. ./databaseTechList.sh list MariaDB 10.6"
}

# Function to populate teriary files
function populateLists(){
    ## Truncate output files
    echo "" > tertiaryFiles/allList.txt
    echo "" > tertiaryFiles/allListSorted.txt
    echo "" > tertiaryFiles/serverList.txt
    echo "" > tertiaryFiles/windowsList.txt
    echo "" > tertiaryFiles/windowsListSorted.txt

	printf "%s\n" \
	"Getting list of projects "\
	"----------------------------------------------------" \
    " "

    ## Array of projects, append project names/IDs to exclude as needed for your own uses
    projectArray=(`gcloud projects list | grep -E -v 'test|PROJECT|temp' | awk '{print $1}'`)


	printf "%s\n" \
	"Getting list of servers"\
	"----------------------------------------------------" \
    " "

    ## For loop to iterate through projects and populate output file with  servers
    for project in "${projectArray[@]}"
    do
            ### Find Windows servers specifically, you may need to adjust this based on your own needs.
            gcloud compute instances list --project="${project}" --format="table(name,zone,disks[].licenses)" | grep -i windows | awk '{print $1}' >> tertiaryFiles/windowsList.txt

            ### Find powered on servers. Write hostnames to server list file. You may need to adjust this based on your own needs.
            gcloud compute instances list --project="${project}" | grep -E -v 'TERMINATED' | awk '{print $1}' >> tertiaryFiles/allList.txt

    done

    ## Sort files
    sort tertiaryFiles/windowsList.txt -o tertiaryFiles/windowsListSorted.txt
    sort tertiaryFiles/allList.txt -o tertiaryFiles/allListSorted.txt

    ## Pick out items unique to allListSorted.txt and write to serverList, should filter out Windows
    comm -13 tertiaryFiles/windowsListSorted.txt tertiaryFiles/allListSorted.txt >> tertiaryFiles/serverList.txt

}

# Function to run program
function runProgram(){
	printf "%s\n" \
	"List" \
	"----------------------------------------------------" \
    " "

    ## Variables
    databaseTech=$1
    techVersion=$2

    ## Validation
    ### Case Statement based on database tech
	printf "%s\n" \
	"Checking database tech passed "\
	"----------------------------------------------------" \
    " "

    case "$databaseTech" in
            ### Postgres
            [Pp][Ss][Qq][Ll]|[Pp][Oo][Ss][Tt][Gg][Rr][Ee][Ss])
                    # Truncate output files
                    echo "Hostname,Psql Version" > databaseTechVersion.csv
                    techShortname="psql"
                    ;;
            ### MySQL
            [Mm][Yy][Ss][Qq][Ll])
                    # Truncate output files
                    echo "Hostname,MySQL Version" > databaseTechVersion.csv
                    techShortname="mysql"
                    ;;
            ### MariaDB
            [Mm][Aa][Rr][Ii][Aa][Dd][Bb])
                    # Truncate output files
                    echo "Hostname,MariaDB Version" > databaseTechVersion.csv
                    techShortname="mariadb"
                    ;;
            ### Fail state
            *)
                    printf "%s\n" \
                    "${red}ISSUE DETECTED - Invalid input detected!" \
                    "----------------------------------------------------" \
                    "Running help script and exiting." \
                    "Re-run script with valid input${normal}"
                    helpFunction
                    exit 1
                    ;;
    esac

    ### Check if techVersion empty
	printf "%s\n" \
	"Checking database version passed "\
	"----------------------------------------------------" \
    " "

    if [[ -z $techVersion ]]; then
            while [[ -z $techVersion ]]; do
                    printf "%s\n" \
                    "${yellow}IMPORTANT: Enter a value for Database version" \
                    "----------------------------------------------------" \
                    "Example Versions: '10', '8.1' ${normal}" \
                    " "

                    read techVersion
            done
    fi

	printf "%s\n" \
	"Populating CSV output file "\
	"----------------------------------------------------" \
    " "

    ## For loop to pick out servers running passed value version of MariaDB
    for i in $(cat tertiaryFiles/serverList.txt)
    do
                    ## Get database tech version
                    if [[ "$techShortname" == "psql" ]]; then
                        databaseTechVersion=$(ssh $i "$techShortname -V" | awk '{print $3}')
                    elif [[ "$techShortname" == "mysql" ]]; then
                        databaseTechVersion=$(ssh $i "$techShortname -V" | awk '{print $3}')
                    elif [[ "$techShortname" == "mariadb" ]]; then
                        databaseTechVersion=$(ssh $i "$techShortname -V" | awk '{print $5}' | rev | cut -c2- | rev)
                    else
                        printf "%s\n" \
                        "${red}ISSUE DETECTED - Invalid input detected!" \
                        "----------------------------------------------------" \
                        "Running help script and exiting." \
                        "Re-run script with valid input${normal}"
                        helpFunction
                        exit
                    fi

                    ## If databaseTechVersion version matches, append to databaseTechVersion spreadsheet
                    if [[ "$databaseTechVersion" == "$techVersion"* ]]; then
                            echo "$i,$databaseTechVersion" >> databaseTechVersion.csv
                    fi
    done

    ## Keep copy of CSV file
    cp databaseTechVersion.csv outputFiles/databaseTechVersion.csv.$(date +%Y%m%d%H%M)
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

	helpFunction
	exit
	;;
[Ll]ist)
	printf "%s\n" \
	"Running script" \
	"----------------------------------------------------" \
    " "

	runProgram $2 $3
	;;
[Pp]opulate)
	printf "%s\n" \
	"Populating lists" \
	"----------------------------------------------------" \
    " "

    populateLists
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
