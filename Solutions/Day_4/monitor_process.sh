#!/bin/bash

. config_file

dir="$(dirname "$0")"
process="$1"
WEBHOOK_URL="YOUR_SLACK_WEBHOOK_URL" # Looks liks 'https://hooks.slack.com/services/XXXXXXXXX/XXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX'
Max_Attempts=3
Sleep=5

fn_running() {
    if systemctl is-active --quiet "$process"; then
        echo "The process '$process' is running."
    else
        echo "The process '$process' is not running, It will be restarted but you need to give some information below"
        read -p "Do you want notification if the restarting of process $process failed? Type Y for yes/N for no:" response
        if [ "$response" == "Y" ] || [ "$response" == "y" ]; then
            echo "You have opted in for notification"
            echo "Checking requirements for notification"
            if [ -s "$dir/config.txt" ]; then
                echo "Config file found and is not empty, continuing the process"
                read -p "Select a mode of notification, Type Y for Email/N for Slack" notification
                if [ "$notification" == "Y" ] || [ "$notification" == "y" ]; then
                    read -rsn1 -p "You have chosen EMAIL as a mode for notification. Press any key to continue." email
                elif [ "$notification" == "N" ] || [ "$notification" == "n" ]; then
                    read -rsn1 -p "You have chosen SLACK as a mode for notification. Press any key to continue." slack
                else
                    echo "Invalid input. Exiting the process."
                    exit
                fi
                fn_restart_m "$process"
            else
                echo "Config file either does not exist or is empty, exiting the process"
                echo "Read README.md and try again....."
                exit
            fi
        else
            if [ "$response" == "N" ] || [ "$response" == "n" ]; then
                echo "You have opted out for notification"
                echo "Continuing"
                fn_restart_n "$process"
            fi
        fi
    fi
}

fn_restart_n() {
    for attempts in $(seq 1 $Max_Attempts); do
        echo "Attempting to restart the process '$process' (Attempt $attempts of $Max_Attempts)..."
        systemctl restart "$process"
        sleep $Sleep
        if systemctl is-active --quiet "$process"; then
            echo "The process '$process' has been restarted successfully."
            return
        fi
    done

    echo "Failed to restart the process '$process' after $Max_Attempts attempts."
}

fn_restart_m() {
    for attempts in $(seq 1 $Max_Attempts); do
        echo "Attempting to restart the process '$process' (Attempt $attempts of $Max_Attempts)..."
        systemctl restart "$process"
        sleep $Sleep
        if systemctl is-active --quiet "$process"; then
            echo "The process '$process' has been restarted successfully."
            return
        fi
    done

    echo "Failed to restart the process '$process' after $Max_Attempts attempts."
    echo "Sending Notification To Your Choosen Mode"
    if [ "$email" -eq "0" ]; then
        fn_notify_m "$process"
    elif [ "$slack" -eq "0" ]; then
        fn_notify_s "$process"
    fi
}

fn_notify_m() {

    local message=$(
        cat <<EOF
From: $username
To: $recipient
Subject: $subject
Content-Type: text/plain; charset=utf-8

$body
EOF
    )

    # Send the email using curl
    curl -url "smtps://$smtp_server:$smtp_port" --ssl-reqd \
        --mail-from "$username" --mail-rcpt "$recipient" \
        --user "$username:$password" -T <(echo -e "$message")
}

fn_notify_s() {

    message="Alert: The process '$process' requires manual intervention after $Max_Attempts restart attempts."

    # Sending the message to Slack using curl
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" "$WEBHOOK_URL"
}

# Check if at least one target process name is provided as a command-line argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <process_name1> [<process_name2> ...]"
    exit 1
fi

# Call the function to check if each process is running
for process in "$@"; do
    fn_running "$process"
done
