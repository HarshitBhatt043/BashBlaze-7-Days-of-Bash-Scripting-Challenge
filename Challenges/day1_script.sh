#!/bin/bash

# Day 1 of the Bash Scripting Challenge
echo "Day 1 of the Bash Scripting Challenge"

# Prompt the user for the first number
read -p "Enter the first number for simple addition: " response1

# Prompt the user for the second number
read -p "Enter the second number for simple addition: " response2

# Perform the addition
sum=$((response1 + response2))

# Wait for user input to display the sum
read -rsn1 -p"To know the sum, press any key"
echo
# Check if the sum is even or odd.
if ((sum % 2 == 0)); then
    echo "The combination of your selected numbers resulted an even number."
else
    echo "The combination of your selected numbers resulted an odd number."
fi
# Print the result of the addition
echo "Result = $sum"

# Wait for user input to display some information
read -rsn1 -p"To see some information about this script, press any key"
echo

# Print information about the script
echo "1 - Script name is $0"
echo "2 - Process ID of the current script is $$"
echo "3 - Number of seconds since the script started are $SECONDS"

# List all files with .sh extension in the current directory
echo "4 - All files with .sh extension in the current directory:"
ls *.sh
