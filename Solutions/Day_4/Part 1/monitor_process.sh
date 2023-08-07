#!/bin/bash

# Define a function to display error messages and exit with an error status
error() {
    echo "Error: $1" >&2
    exit 1
}

# Check for sudo privileges
if ! sudo -v; then
    error "This script requires sudo privileges for check and restart stage. Try again with sudo."
fi

# Function to check if a command is available, and install it if not
check() {
    if ! command -v "$1" &>/dev/null; then
        echo "$1 not found. Installing..."
        # Try to update and install the package
        if sudo apt-get update && sudo apt-get install -y "$1"; then
            echo "$1 installed successfully."
        else
            error "Failed to install $1."
        fi
    fi
}

# Check for required commands
check wget
check curl

# Check if the config file exists and source it, or download the default config
if [ -s "config.txt" ]; then
    echo "Config file found, make sure you are using your own values inside the config file"
    . config.txt || error "Failed to source config.txt"
else
    echo "Config file not found or empty, a default one will be downloaded..."
    if wget -q "https://github.com/HarshitBhatt043/BashBlaze-7-Days-of-Bash-Scripting-Challenge/blob/main/Solutions/Day_4/Part%201/config.txt"; then
        echo "Default config file downloaded"
        . config.txt || error "Failed to source config.txt"
    else
        error "Failed to download config.txt"
    fi
fi

# Function to check if a process is running and restart it if needed
fn_running() {
    if systemctl is-active --quiet "$process"; then
        echo "The process '$process' is running."
    else
        echo "The process '$process' is not running, It will be restarted but you need to give some information below"
        read -p "Do you want notification if the restarting of process $process failed? Type Y for yes/N for no: " response
        if [ "$response" == "Y" ] || [ "$response" == "y" ]; then
            echo "You have opted in for notification"
            echo
            read -rn1 -p "Select a mode of notification, Type Y for Email/N for Slack: " notification

            if [[ "$notification" != [YyNn] ]]; then
                echo "Invalid input. Exiting the process."
                exit
            fi

            fn_restart_y || error "Failed to restart the process"

        else
            if [ "$response" == "N" ] || [ "$response" == "n" ]; then
                echo "You have opted out for notification"
                fn_restart_n || error "Failed to restart the process"
            fi
        fi
    fi
}

# Function to restart a process with a certain number of attempts
fn_restart_n() {
    for attempts in $(seq 1 $Max_Attempts); do
        echo "Attempting to restart the process '$process' (Attempt $attempts of $Max_Attempts)..."
        sudo systemctl restart "$process"
        sleep $Sleep
        if systemctl is-active --quiet "$process"; then
            echo "The process '$process' has been restarted successfully."
            return
        elif [ "$attempts" -ge "$Max_Attempts" ]; then
            error "Failed to restart the process '$process' after $Max_Attempts attempts"
        fi
    done
}

# Function to restart a process with a certain number of attempts and send notifications
fn_restart_y() {
    for attempts in $(seq 1 $Max_Attempts); do
        echo "Attempting to restart the process '$process' (Attempt $attempts of $Max_Attempts)..."
        sudo systemctl restart "$process"
        sleep $Sleep
        if systemctl is-active --quiet "$process"; then
            echo "The process '$process' has been restarted successfully."
            return
        fi
    done

    echo "Failed to restart the process '$process' after $Max_Attempts attempts."
    echo "Sending Notification To Your Choosen Mode"
    if [ "$notification" == "Y" ] || [ "$notification" == "y" ]; then
        # Check if default values are still being used in the config file
        grep -q "your_" config.txt && error "You are still using default values. Check Readme.md and try again."
        fn_notify_m
    elif [ "$notification" == "N" ] || [ "$notification" == "n" ]; then
        # Check if default values are still being used in the config file
        grep -q "XXXXXXXX" config.txt && error "You are still using default values. Check Readme.md and try again."
        fn_notify_s
    fi
}

# Function to send email notifications
fn_notify_m() {
    # Send the email using curl
    curl -url "smtps://$smtp_server:$smtp_port" --ssl-reqd \
        --mail-from "$username" --mail-rcpt "$recipient" \
        --user "$username:$password" -T <(echo -e "$mail") || error "Failed to send email notification"
}

# Function to send Slack notifications
fn_notify_s() {
    # Sending the message to Slack using curl
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$slack\"}" "$Webhook" || error "Failed to send Slack notification"
}

# Check if at least one target process name is provided as a command-line argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <process_name1> [<process_name2> ...]"
    exit 1
fi

# Call the function to check if each process is running
for process in "$@"; do
    fn_running "$process" || error "Error occurred while checking or restarting the process '$process'"
done
