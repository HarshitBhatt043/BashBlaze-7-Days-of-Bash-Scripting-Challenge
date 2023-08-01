#!/bin/bash

# Get the directory path to be backed up from the command-line argument
backup_dir=$1

# Create a timestamped backup folder path
backup_path=$backup_dir/backup/backup_$(date +"%Y-%m-%d_%H-%M-%S")

# Get a list of existing backup directories inside the specified backup directory
list=$backup_dir/backup/*

# Sort the list of backup directories based on modification time (newest first)
sorted_list=($(echo "${list[*]}" | sort -r))

# Print status message for requirements check
echo "Checking Requirements"
echo

# Check if the script is executed with exactly one argument
if [ $# -ne 1 ]; then
    echo "Requirements check failed, the $# arguments you provided are wrong"
    echo
    echo "How to use $0 -: $0 <directory_path>"
    echo
    echo "Exiting $0, TRY AGAIN"
    exit 1

# Check if the specified backup directory exists
elif [ -d "$backup_dir" ]; then
    echo "Creating backup folder"
    # Create the backup directory path
    mkdir -p "$backup_path"
    echo
    echo "Folder created -: $backup_path"
    echo
    echo "Requirement Check successful, backup directory found -: $backup_path"
    echo
    echo "All Requirements Check Passed"

# If the specified backup directory does not exist, create it and the backup folder path
else
    echo "Requirements check failed $backup_dir directory not found"
    echo
    echo "Creating $backup_dir and $backup_path"
    echo
    # Create the backup directory path
    mkdir -p "$backup_path"
    echo "Folder created -: $backup_path"
    # Check if the backup folder path was created successfully
    if [ -d "$backup_path" ]; then
        echo
        echo "Requirement Check successful, backup directory found -: $backup_path"
        echo
        echo "All Requirements Check Passed"
    fi
fi

# Start the backup process
echo "Backing up files"
echo
# Copy all files from the specified directory to the backup folder
cp -r "$backup_dir" "$backup_path"

# Check if there are at least three backups in the sorted list
if [ "${#sorted_list[@]}" -ge 3 ]; then
    # Calculate the number of old backups to remove (keeping the last 3)
    remove=$((${#sorted_list[@]} - 2))
    echo "Removing $remove old backups..."
    # Remove the oldest backups to maintain only the last 3 backups
    for ((i = 0; i < remove; i++)); do
        rm -rf "${sorted_list[$i]}"
    done
fi