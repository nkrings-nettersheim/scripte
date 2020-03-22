#!/bin/bash
filename_1="media_$(date +%Y-%m-%d -d "3 day ago").tar.gz"
filename_2="mysqldump_backup_$(date +%Y-%m-%d -d "3 day ago")_prod.sql.tar.gz"
./dropbox_uploader.sh delete $filename_1
./dropbox_uploader.sh delete $filename_2

