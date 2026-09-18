# ListScripts

## Overview
BASH scripts for listing servers matching criteria in GCP. Useful for upgrade projects.

## Scripts
* **centos-list**, A BASH script for listing CentOS 7 servers in GCP.
* **disk-find**, A BASH script for finding disk types across projects. <br>
  Usage. `./disk-find.sh DISK_TYPE` <br>
  Ex. `./disk-find.sh pd-standard` <br>
* **database-tech-list**, A BASH script for listing MariaDB, MySQL and Postgres daugs and whatever version of the tech they're running. Takes a database tech and version as arguments. <br>
  Usage. `./database-tech-list.sh list DATABASE_TECH TECH_VERSION` <br>
  Ex. `./database-tech-list.sh list mysql 8` <br>
  Also has a populate command for generating new server lists to check. <br>
  Usage. `./database-tech-list.sh populate` <br>
* **php-list**, A BASH script for list Welshes, Stantzes and Image servers alongside their PHP versions. Takes a PHP version as an argument. <br>
  Usage. `./php-list.sh PHP_VERSION` <br>
  Ex. `./php-list.sh 8.1` <br>
* **ubuntu-list**, A BASH script for listing Ubuntu servers in GCP.
* **windows-list**, A BASH script for listing Windows servers in GCP. Two options: <br>
  - **display**, lists all Windows servers across all projects.
  - **list**, lists servers in all projects following a license regex. Useful for OS upgrades.
