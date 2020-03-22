#!/bin/bash
filename="media_$(date +%Y-%m-%d -d "3 day ago").tar.gz"
./dropbox_uploader.sh delete $filename

