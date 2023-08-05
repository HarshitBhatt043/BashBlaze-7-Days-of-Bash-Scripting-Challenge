#!/bin/bash

process="$1"
attempts=3

fn_process() {
    local status
    status=$(sudo systemctl status "$process" 2>/dev/null)

    if [ -n "$status" ] && [[ "$status" != *"inactive"* ]] && [[ "$status" != *"failed"* ]]; then
        echo "Process $process is running. Attempting to restart using systemctl..."
        fn_systemd
    else
        echo "Failed to find the process $process managed by systemctl. Attempting to start directly..."
        fn_direct
    fi
}

fn_systemd() {
    for ((i = 1; i <= attempts; i++)); do
        echo "Attempting to restart $process using systemctl (Attempt $i)..."
        sudo systemctl restart "$process"

        sleep 5

        if pidof -x "$process" >/dev/null; then
            echo "Process $process has been restarted successfully."
        else
            echo "Failed to restart $process."
        fi
    done

    echo "Failed to restart $process after $attempts attempts. Manual intervention required."
    #fn_mail
}

fn_direct() {
    for ((i = 1; i <= attempts; i++)); do
        echo "Attempting to restart $process (Attempt $i)..."

        local process_command=$(which "$process")
        if [ -n "$process_command" ]; then

            "$process_command" &
        else
            echo "Failed to find the command to start $process_name. Manual intervention may be required."
            # fn_mail
            return
        fi

        sleep 5

        if pidof -x "$process" >/dev/null; then
            echo "Process $process has been restarted successfully."
            return
        fi
    done

    echo "Failed to restart $process after $attempts attempts. Manual intervention required."
    #fn_mail
}

#fn_mail() {

#    local recipient_email="admin@example.com"
#    local subject="Process Restart Failed for $process"
#    local body="The process $process has failed to restart after $attempts attempts. Manual intervention is required."

#    echo "$body" | mail -s "$subject" "$recipient_email"
#}

if [ $# -eq 0 ]; then
    echo "Usage: $0 <process1> <process2> ..."
    exit 1
fi

for process in "$@"; do

    fn_process "$process"
done
