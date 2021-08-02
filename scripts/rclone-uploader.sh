#!/bin/bash
set -e

# RClone Config file
RCLONE_CONFIG=/home/robot/.config/rclone/rclone.conf; export RCLONE_CONFIG
RCLONE_USER_AGENT=animosityapp; export RCLONE_USER_AGENT

# Local Drive - This must be a local mount point on your server that is used for the source of files
# WARNING: If you make this your rclone Google Drive mount, it will create a move loop
# and DELETE YOUR FILES!
# Make sure to set this to the local path you are moving from!!
LOCAL=/mnt/sdb/mergerfs/local

# Exit if running
if [[ $(pidof -x "$(basename "$0")" -o %PPID) ]]; then
echo "Already running, exiting..."; exit 1; fi

# Check for excludes file
if [[ ! -f /home/robot/scripts/excludes ]]; then
echo "excludes file not found, aborting..."; exit 1; fi

# Is $LOCAL actually a local disk?
if /bin/findmnt $LOCAL -o FSTYPE -n | grep fuse; then
echo "FUSE file system found, exiting..."; exit 1; fi

# Move older local files to the cloud...
/usr/bin/rclone move $LOCAL GDrive-Media-1: --exclude-from /home/robot/scripts/excludes --log-file /home/robot/logs/rclone-uploader.log --delete-empty-src-dirs --fast-list --drive-stop-on-upload-limit --progress