# GCP scripts

## Overview
A collection of scripts for servers hosted in the Google Cloud Project. For best results use them in a `~/bin` folder. <br>

## Scripts
All scripts have a built in help function, just pass `help` as an argument. <br>
* **cloud-scp.sh**, A BASH script for copying local files to a remote server. <br>
  Takes an action, filepath, hostname, zone, and project as arguments. <br>
  Optionally provide an SSH key filepath. <br>
  Do not run as root or with root perms. <br>
  May need adjusted depending on configuration. <br>
  Usage, `./cloud-scp.sh copy /path/to/file hostname zone project (optional) /path/to/ssh/key`. <br>
  Also has a built in 'help' function by passing help as an argument. <br>
* **cloud-ssh.sh**, A BASH script for connecting to GCP linux servers using the gcloud compute command.
  Takes a server, zone and project for arguments. <br>
  Usage, `cloud-ssh.sh server zone project`<br>
  Can also take an SSH key file as an argument. Use a private key. <br>
  Usage, `cloud-ssh.sh server zone project /path/to/sshkey`.<br>
* **console-log.sh**, List output from the GCP Console Log for a server.
  Takes an action, hostname, zone and project as an argument. <br>
  Usage, `console-log.sh log hostname zone project` <br>
* **create-gcp-image.sh** A BASH script for creating a GCP image from a GCP disk. Takes an image name, disk name, zone and project as arguments. <br>
  Remember to power the server off first! <br>
  Usage. `./create-gcp-image.sh.sh create IMAGE_NAME DISK_NAME ZONE PROJECT` <br>
* **detached-disk.sh**, A BASH script for listing disks without servers. Iterates through all projects with Google Cloud SDK API active. <br>
  Usage, `./detached-disk.sh list` <br>
* **disk-list.sh**, A BASH script for finding a disk in a project. Takes a server and project as an
argument. Useful in cases where a disk has an unusual name, such as from a snapshot restoration. <br>
  Usage, `./disk-list.sh hostname project` <br>
* **gcp-restart.sh**, a BASH script for restarting a server. <br>
  Takes a hostname, zone and project as arguments <br>
  Usage, `gcp-restart.sh hostname zone project` <br>
* **generate-hosts**, A BASH script for generating a host file using GCP servers. <br>
  Usage, just run the script. <br>
* **kb-connect.sh**, a BASH script for connecting or listing Kubernetes Pods in GCP <br>
  To list all pods in a project pass the 'pods' argument. Can also look for
  a specific pod by passing part of it's alias.<br>
  I.e. If you were looking for a pod `webapp2-lalwlih-22355` you could pass it `webapp2`. <br>
  Usage, `./kb-connect.sh pods` <br>
  Usage, `./kb-connect.sh pods alias` <br>
  To list all ingress public IPs pass the 'ingress' argument.
  Can pass an alias to look for a specific pods public IP. <br>
  Usage, `./kb-connect.sh ingress` <br>
  Usage, `./kb-connect.sh ingress alias` <br>
  To connect to a pod pass the 'connect' argument and the pod alias.
  Passing the connect argument without passing an alias will list all the pod aliases. Copy/Paste the alias to connect from list.<br>
  Usage, `./kb-connect.sh connect` <br>
  Usage, `./kb-connect.sh connect pod` <br>
* **list-scripts**, BASH scripts for listing servers w/ specific attributes <br>
* **project-list**, A BASH script for listing all servers in a GCP project. <br>
  Takes a project as an argument. Can match partials. <br>
  Usage, `project-list project`<br>
* **snapshot.sh**, A BASH script for taking a snapshot of a GCP server. <br>
  Script can create standard or archive snapshots. Pass standard or archive as flags. <br>
  Standard snapshots take server name, reason for snapshot, sysadmin initials, and project as arguments. <br>
  Usage, `./snapshot.sh standard hostname reason intials project` <br>
  Ex. `./snapshot.sh standard serverName wp ngg myProject` <br>
  Archive snapshots take hostname reason for snapshot, and project as arguments. <br>
  Server should be powered off for best result. <br>
  Usage, `./snapshot.sh archive hostname purpose project` <br>
  Ex. `./snapshot.sh archive serverName storage myProject` <br>
  Depending on your project configuration the archive function may need expansion such as labels for customer names or unique properties for your needs. <br>
* **snapshot-removal.sh**, a BASH script for removing snapshots over a week old. <br>
  Takes a run command and search criteria (like initials) as arguments <br>
  Usage, `./snapshot-removal.sh action criteria` <br>
  Example using my initials, `./snapshot-removal.sh remove ngg` <br>
  Works best from a cron, i.e, <br>
  `5 16 * * 5 /bin/bash ~/bin/snapshot-removal.sh remove ngg > /dev/null 2>&1` <br>
* **update-gcp-service-accounts**, BASH script to attach a Service Account to a server. Takes hostname, project and zone from an input file. <br>
  Usage, `./update-gcp-service-accounts.sh run /path/to/input-file.txt`
