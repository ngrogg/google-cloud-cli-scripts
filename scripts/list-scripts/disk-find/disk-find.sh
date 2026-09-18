#!/usr/bin/env bash

# Disk Find
# BASH script to find all instances of a disk type across projects
# By Nicholas Grogg
# Revision: 20260422

# Set exit on error
set -e

if [[ $1 == "help" || $1 == "Help" ]]; then
    echo "Find disks across projects that match a criteria type"
    echo "Usage. ./diskFind.sh DISK_TYPE"
    echo "Ex. ./diskFind.sh pd-standard"
fi

if [[ -z $1 ]]; then
    echo "Argument not provided, exiting!"
    echo "Usage. ./diskFind.sh DISK_TYPE"
    echo "Ex. ./diskFind.sh pd-standard"
    exit 1
fi

# Assign provided diskType value to variable
diskType=$1

# Generate array of projects, adjust regex as needed
projectArray=(`gcloud projects list | grep -E -v 'PROJECT_ID|^development|^test' | awk '{print $1}'`)

# Create folders as needed if they don't exist
if [[ ! -d interimFiles ]]; then
    mkdir interimFiles
fi

if [[ ! -d outputFiles ]]; then
    mkdir outputFiles
fi

# Create final output csv file for script
echo "name,size,project" > diskFindOutput.csv

# Iterate through array of projects looking for disks that match the provided disk type
for project in "${projectArray[@]}"; do
    ## Append disks to csv, remove first line of output
    gcloud compute disks list --project="${project}" --filter="type:$diskType" --format='csv(name,sizeGb)' | tail -n +2 > interimFiles/${project}.csv

    ## Append project to each line of csv file if csv file has any words at all in it
    if [[ $(wc -w interimFiles/${project}.csv | awk '{print $1}') -gt 0 ]]; then
        sed -i "s/$/,${project}/" interimFiles/${project}.csv
    fi
done

# Combine interim files into one master CSV file, only add files if not empty
for file in $(ls interimFiles/); do
    if [[ $(wc -w interimFiles/$file | awk '{print $1}') -gt 0 ]]; then
        cat interimFiles/$file >> diskFindOutput.csv
    fi
done

# Back up master csv w/ timestamp
cp diskFindOutput.csv outputFiles/diskFindOutput.$(date +%Y%m%d%H%M).csv
