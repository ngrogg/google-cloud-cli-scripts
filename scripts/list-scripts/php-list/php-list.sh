#!/usr/bin/env bash

# PHP List
# BASH script to find Linux servers and output their PHP versions
# By Nicholas Grogg
# Revision: 20260918

# Set exit on error
set -e

if [[ $1 == "Help" || $1 == "help" ]]; then
    echo "Php List -- Help"
    echo "----------------------------------------------------"
    echo "Usage. ./php-list.sh PHPVERSION"
    echo "Ex. ./php-list.sh 8.1"
    exit 0
fi

php_check_version=$1

if [[ -z $php_check_version ]]; then
    while [[ -z $php_check_version ]]; do
        echo "Enter a PHP version like 8.0 :"
        read php_check_version
    done
fi

# Array of projects, append project names/IDs to exclude as needed for your own uses
project_array=(`gcloud projects list | grep -E -v 'test|PROJECT|temp' | awk '{print $1}'`)

# Truncate server list
echo "" > tertiary-files/server-list.txt
echo "" > tertiary-files/all-list.txt
echo "" > tertiary-files/all-list-sorted.txt
echo "" > tertiary-files/server-list.txt
echo "" > tertiary-files/windows-list.txt
echo "" > tertiary-files/windows-list-sorted.txt

# For loop to iterate through projects and populate output file with  servers
for project in "${project_array[@]}"
do
    ## Find Windows servers specifically, you may need to adjust this based on your own needs.
    gcloud compute instances list --project="${project}" --format="table(name,zone,disks[].licenses)" | grep -i windows | awk '{print $1}' >> tertiary-files/windows-list.txt

    ## Find powered on servers. Write hostnames to server list file. You may need to adjust this based on your own needs.
    gcloud compute instances list --project="${project}" | grep -E -v 'TERMINATED' | awk '{print $1}' >> tertiary-files/all-list.txt

done

# Sort files
sort tertiary-files/windows-list.txt -o tertiary-files/windows-list-sorted.txt
sort tertiary-files/all-list.txt -o tertiary-files/all-list-sorted.txt

## Pick out items unique to all-list-sorted.txt and write to server-list, should filter out Windows
comm -13 tertiary-files/windows-list-sorted.txt tertiary-files/all-list-sorted.txt >> tertiary-files/server-list.txt

## Truncate output files
echo "Hostname,PHP Version" > php-version.csv

# For loop to pick out servers running PHP
for i in $(cat tertiary-files/server-list.txt)
do
    ## Check for PHP Version 8, update version as needed
    php_found_version=$(ssh $i "php --version | grep PHP\ $php_check_version" | awk '{print $2}')

    ## If PHP 8, append to PHP Version 8 spreadsheet. Update version as needed
    if [[ "$php_found_version" == *"$php_check_version"* ]]; then
        echo "$i,$php_found_version" >> php-version.csv
    fi
done
