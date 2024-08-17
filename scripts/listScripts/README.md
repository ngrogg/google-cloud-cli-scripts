# ListScripts

## Overview
BASH scripts for listing servers matching criteria in GCP. Useful for upgrade projects.

## Scripts
* **centosList**, A BASH script for listing CentOS 7 servers in GCP.
* **databaseTechList**, A BASH script for listing MariaDB, MySQL and Postgres daugs and whatever version of the tech they're running. Takes a database tech and version as arguments. <br>
  Usage. `./databaseTechList.sh list DATABASE_TECH TECH_VERSION` <br>
  Ex. `./databaseTechList.sh list mysql 8` <br>
  Also has a populate command for generating new server lists to check. <br>
  Usage. `./databaseTechList.sh populate` <br>
