# GCP scripts

## Overview
A collection of scripts for servers hosted in the Google Cloud Project. Named without .sh as I use them in a `~/bin` folder. <br>

## Scripts
All scripts have a built in help function, just pass `help` as an argument. <br>
* **cloudssh**, A BASH script for connecting to GCP linux servers using the gcloud compute command.
  Takes a server, zone and project for arguments. <br>
  Usage, `cloudssh server zone project`<br>
* **consolelog**, List output from the GCP Console Log for a server.
  Takes an action, hostname, zone and project as an argument. <br>
  Usage, `consolelog log hostname zone project` <br>
* **diskList**, A BASH script for finding a disk in a project. Takes a server and project as an
argument. Useful in cases where a disk has an unusual name, such as from a snapshot restoration. <br>
  Usage, `./diskList hostname project` <br>
* **gcpRestart**, a BASH script for restarting a server. <br>
  Takes a hostname, zone and project as arguments <br>
  Usage, `gcpRestart hostname zone project` <br>
* **generateHosts**, A BASH script for generating a host file using GCP servers. <br>
  Usage, just run the script. <br>
* **kbConnect**, a BASH script for connecting or listing Kubernetes Pods in GCP <br>
  To list all pods in a project pass the 'pods' argument. Can also look for
  a specific pod by passing part of it's alias.<br>
  I.e. If you were looking for a pod `webapp2-lalwlih-22355` you could pass it `webapp2`. <br>
  Usage, `./kbConnect pods` <br>
  Usage, `./kbConnect pods alias` <br>
  To list all ingress public IPs pass the 'ingress' argument.
  Can pass an alias to look for a specific pods public IP. <br>
  Usage, `./kbConnect ingress` <br>
  Usage, `./kbConnect ingress alias` <br>
  To connect to a pod pass the 'connect' argument and the pod alias.
  Passing the connect argument without passing an alias will list all the pod aliases. Copy/Paste the alias to connect from list.<br>
  Usage, `./kbConnect connect` <br>
  Usage, `./kbConnect connect pod` <br>
* **listScripts**, BASH scripts for listing servers w/ specific attributes <br>
* **projectlist**, A BASH script for listing all servers in a GCP project. <br>
  Takes a project as an argument. Can match partials. <br>
  Usage, `projectlist project`<br>
* **snapshot**, A BASH script for taking a snapshot of a GCP server. Takes server name, reason for snapshot,
  sysadmin initials, and project as arguments. <br>
  Usage, `./snapshot hostname reason intials project` <br>
  Ex. `./snapshot serverName wp ngg myProject` <br>
* **snapshotRemoval**, a BASH script for removing snapshots over a week old. <br>
  Takes a run command and search criteria (like initials) as arguments <br>
  Usage, `./snapshotRemoval action criteria` <br>
  Example using my initials, `./snapshotRemoval remove ngg` <br>
  Works best from a cron, i.e, <br>
  `5 16 * * 5 /bin/bash ~/bin/snapshotRemoval remove ngg > /dev/null 2>&1` <br>
