#!/usr/bin/bash

# Generate Hosts
# BASH script to generate a potential host file
# Usage, just run the script
# By Nicholas Grogg

# Generate array of projects, fill in any projects to exclude
projectArray=(`gcloud projects list | grep -E -v 'add|projects|here' | awk '{print $1}'`)

# Generate output file, truncate if already existing
echo "# GCP Hosts" > generateHostsOutput.txt

# Iterate through list and append output to file above
for project in "${projectArray[@]}"
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
    }' >> generateHostsOutput.txt
done

# Append section for site testing
echo " " >> generateHostsOutput.txt
echo "# Site Testing" >> generateHostsOutput.txt
echo " " >> generateHostsOutput.txt
