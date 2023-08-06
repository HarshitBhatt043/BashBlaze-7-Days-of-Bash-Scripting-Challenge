#!/bin/bash

if [ -s "config.txt" ]; then
    echo "Config file found, Make sure that your are using your own values inside config file"
    . config.txt
else
    echo "Config file not found OR empty, a deffault one will be downloaded...."
    wget -q "https://github.com/HarshitBhatt043/BashBlaze-7-Days-of-Bash-Scripting-Challenge/blob/monitoring-feature/Solutions/Day_4/config.txt"
    echo "Default config file downloaded"
fi

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
            fn_restart_y "$process"

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
        sudo systemctl restart "$process"
        sleep $Sleep
        if systemctl is-active --quiet "$process"; then
            echo "The process '$process' has been restarted successfully."
            return
        fi
    done

    echo "Failed to restart the process '$process' after $Max_Attempts attempts."
}

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
        fn_notify_m "$process"
    elif [ "$notification" == "N" ] || [ "$notification" == "n" ]; then
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
    # Sending the message to Slack using curl
    curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$slack\"}" "$Webhook"
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
