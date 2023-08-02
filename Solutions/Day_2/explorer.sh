#!/bin/bash

# Welcome message
echo 'Welcome to the Interactive File and Directory Explorer!'
echo

# Infinite loop for file and directory exploration
while true; do
    echo "=== Files and Directories In Current Path ==="
    echo

    # Loop through each content (file or directory) in the current path
    for content in *; do
        # Check if the content is a file
        if [[ -f "$content" ]]; then
            # Retrieve file size in human-readable format (e.g., 1.5 MB, 10 KB)
            size=$(ls -lah "$content" | awk '{print $5}' | sed 's/\([0-9.]\)\([A-Za-z]\)/\1 \2/')
            echo "- $content ("$size"B)"
        # Check if the content is a directory
        elif [[ -d "$content" ]]; then
            # Retrieve the number of files and directories within the directory
            size=$(ls -lah "$content" | grep "^t" | awk '{print $2}' | sed 's/\([0-9.]\)\([A-Za-z]\)/\1 \2/')
            echo "- $content ("$size"B)"
        fi
    done

    # Prompt the user to refresh or exit
    read -p "Press Enter to refresh or type 'exit' to quit: " response

    # Check if the user wants to exit
    if [[ "$response" == "exit" ]]; then
        echo "Exiting the explorer..."
        break
    fi
done

# Welcome message for character counting
echo "Character counting of a text string"
echo

# Infinite loop for character counting
while true; do
    # Prompt the user to enter text or exit
    read -p "Type any text here OR press ENTER (without any text) to quit: " response

    # Check if the user wants to exit
    if [[ "$response" == "" ]]; then
        echo "Exiting the explorer..."
        break
    else
        # Count the characters in the input text
        count=$(echo -n "$response" | wc -m)
        echo "Character Count: "$count""
    fi
done
