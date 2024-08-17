#!/usr/bin/bash

# PHP List
# BASH script to find Linux servers and output their PHP versions
# By Nicholas Grogg

if [[ $1 == "Help" || $1 == "help" ]]; then
        echo "Php List -- Help"
	    echo "----------------------------------------------------"
        echo "Usage. ./phpList.sh PHPVERSION"
        echo "Ex. ./phpList.sh 8.1"
        exit 0
fi

phpCheckVersion=$1

if [[ -z $phpCheckVersion ]]; then
        while [[ -z $phpCheckVersion ]]; do
                echo "Enter a PHP version like 8.0 :"
                read phpCheckVersion
        done
fi

# Array of projects, append project names/IDs to exclude as needed for your own uses
projectArray=(`gcloud projects list | grep -E -v 'test|PROJECT|temp' | awk '{print $1}'`)

# Truncate server list
echo "" > tertiaryFiles/serverList.txt
echo "" > tertiaryFiles/allList.txt
echo "" > tertiaryFiles/allListSorted.txt
echo "" > tertiaryFiles/serverList.txt
echo "" > tertiaryFiles/windowsList.txt
echo "" > tertiaryFiles/windowsListSorted.txt

# For loop to iterate through projects and populate output file with  servers
for project in "${projectArray[@]}"
do
    ## Find Windows servers specifically, you may need to adjust this based on your own needs.
    gcloud compute instances list --project="${project}" --format="table(name,zone,disks[].licenses)" | grep -i windows | awk '{print $1}' >> tertiaryFiles/windowsList.txt

    ## Find powered on servers. Write hostnames to server list file. You may need to adjust this based on your own needs.
    gcloud compute instances list --project="${project}" | grep -E -v 'TERMINATED' | awk '{print $1}' >> tertiaryFiles/allList.txt

done

# Sort files
sort tertiaryFiles/windowsList.txt -o tertiaryFiles/windowsListSorted.txt
sort tertiaryFiles/allList.txt -o tertiaryFiles/allListSorted.txt

## Pick out items unique to allListSorted.txt and write to serverList, should filter out Windows
comm -13 tertiaryFiles/windowsListSorted.txt tertiaryFiles/allListSorted.txt >> tertiaryFiles/serverList.txt

## Truncate output files
echo "Hostname,PHP Version" > phpVersion.csv

# For loop to pick out servers running PHP
for i in $(cat tertiaryFiles/serverList.txt)
do
                ## Check for PHP Version 8, update version as needed
                phpFoundVersion=$(ssh $i "php --version | grep PHP\ $phpCheckVersion" | awk '{print $2}')

                ## If PHP 8, append to PHP Version 8 spreadsheet. Update version as needed
                if [[ "$phpFoundVersion" == *"$phpCheckVersion"* ]]; then
                        echo "$i,$phpFoundVersion" >> phpVersion.csv
                fi
done
