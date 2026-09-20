#!/usr/bin/env bash

# Generate Hosts
# BASH script to generate a potential host file
# By Nicholas Grogg
# Revision: 20260918

# Set exit on error
set -e

# Generate array of projects, TODO: fill in any projects to exclude
project_array=(`gcloud projects list | grep -E -v 'add|projects|here' | awk '{print $1}'`)

# Generate output file, truncate if already existing
echo "# GCP Hosts" > generate_hosts_output.txt

# Iterate through list and append output to file above
for project in "${project_array[@]}"
do
    ## List project, parse out IP and hostname
    gcloud compute instances list --project $project | awk '{
        for (i=1; i<=NF; i++) {
            if ($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) {
                ip = $i
                hostname = $1
                print ip, hostname
                break
            }
        }
    }' >> generate_hosts_output.txt
done

# Append section for site testing
echo " " >> generate_hosts_output.txt
echo "# Site Testing" >> generate_hosts_output.txt
echo " " >> generate_hosts_output.txt
