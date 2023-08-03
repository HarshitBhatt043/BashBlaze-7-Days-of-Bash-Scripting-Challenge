#!/bin/bash
ESC=$(printf '\033') RESET="${ESC}[0m" BLACK="${ESC}[30m" RED="${ESC}[31m"
GREEN="${ESC}[32m" YELLOW="${ESC}[33m" BLUE="${ESC}[34m" MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m" WHITE="${ESC}[37m" DEFAULT="${ESC}[39m"

whiteprint() { printf "${WHITE}%s${RESET}\n" "$1"; }
greenprint() { printf "${GREEN}%s${RESET}\n" "$1"; }
blueprint() { printf "${BLUE}%s${RESET}\n" "$1"; }
redprint() { printf "${RED}%s${RESET}\n" "$1"; }
yellowprint() { printf "${YELLOW}%s${RESET}\n" "$1"; }
magentaprint() { printf "${MAGENTA}%s${RESET}\n" "$1"; }
cyanprint() { printf "${CYAN}%s${RESET}\n" "$1"; }

fn_hidden() {
    echo ""
    echo "This is an argument script, You need to supply arguments..."
    echo ""
    fn_use
    sleep 6s
    read -p "Still want to continue? Press ENTER or type 'quit' to exit: " hidden
    if [ -z "$hidden" ]; then
        sleep 1s
        echo ""
        echo "LOADING...."
        sleep 2s
        echo ""
        echo "TRANSFORMING......."
        sleep 3s
        echo ""
        echo "********************"
        echo "* ✔✔✔✔✔ DONE ✔✔✔✔✔ *"
        echo "********************"
    elif [ "$hidden" == "quit" ]; then
        fn_quit
    else
        echo "Invalid option. Please press ENTER or type 'quit' to exit."
        fn_hidden
    fi
}

fn_use() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -c, --create  Create a new user account."
    echo "  -d, --delete  Delete an existing user account."
    echo "  -r, --reset   Reset password for an existing user account."
    echo "  -l, --list    Detailed list of all user accounts on the system."
    echo "  -m, --modify  Modify user properties"
    echo "  -h, --help    Show this help message"

}

fn_quit() {
    echo "Bye bye."
    exit 0
}

fn_wrong() { echo "Wrong option,try again." exit 1; }

fn_useradd() {
    echo
    read -p "Enter the number of users to create: " num_users

    if [[ ! "$num_users" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Invalid input. Please enter a positive integer greater than zero."
        exit 1
    fi

    if ! sudo -v; then
        echo "Error: This script requires sudo privileges to create users."
        exit 1
    fi

    for ((i = 1; i <= $num_users; i++)); do
        read -p "Enter username for user $i: " username

        if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
            echo "Error: Invalid username format. Usernames must start with a lowercase letter or underscore, followed by lowercase letters, digits, hyphens, or underscores."
            continue
        fi

        if id "$username" &>/dev/null; then
            echo "User '$username' already exists."
        else
            read -p "Do you want the password to be shown on screen,if yes press 1" response
            if [ $response -eq 1 ]; then
                read -p "Enter password for user $i: " password
            else
                read -s -p "Enter password for user $i: " password
            fi

            if [[ ${#password} -ge 8 ]]; then
                sudo useradd -m "$username"
                useradd_status=$?
                if [ $useradd_status -eq 0 ]; then
                    echo "$username:$password" | sudo chpasswd
                    chpasswd_status=$?
                    if [ $chpasswd_status -eq 0 ]; then
                        grep -w "^$username" /etc/passwd
                        echo "User account $username created successfully!"
                    else
                        echo "Error: Failed to set password for user '$username'."
                        sudo userdel -r "$username"
                    fi
                else
                    echo "Error: Failed to create user '$username'."
                fi
            else
                echo "Error: Password must be at least 8 characters long."
            fi
        fi
    done
}

fn_userdel() {
    echo
    read -p "Enter the number of users to delete: " num_users

    if [[ ! "$num_users" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Invalid input. Please enter a positive integer greater than zero."
        exit 1
    fi

    if ! sudo -v; then
        echo "Error: This script requires sudo privileges to create users."
        exit 1
    fi

    for ((i = 1; i <= $num_users; i++)); do
        read -p "Do you know the username for user $i: ,if yes press 1 " yes

        if [ $yes -eq 1 ]; then
            read -p "Enter username for user $i: " username

            if id "$username" &>/dev/null; then
                sudo userdel -r $username
                if [ $userdel_status -eq 0 ]; then
                    echo "User account '$username' deleted successfully!"
                else
                    echo "Error: Failed to delete user '$username'. Please check permissions or other issues."
                fi
            else
                echo "User '$username' does not exist."
            fi

        else
            echo "All Users In System Are Listed Below"
            echo ""
            echo ""
            awk -F":" '{print $1}' /etc/passwd | sed -e 'N;N;N;N;s/\n/ /g'
            read -p "Enter username from above for user $i: " username
        fi

        if [[ -z "$username" ]]; then
            echo "Error: Invalid username. Please enter a valid username."
            continue
        fi

        if [[ "$username" == "root" ]]; then
            echo "Error: Cannot delete the root user."
            continue
        fi

        if id "$username" &>/dev/null; then
            sudo userdel -r $username
            userdel_status=$?
            if [ $userdel_status -eq 0 ]; then
                echo "User account '$username' deleted successfully!"
            else
                echo "Error: Failed to delete user '$username'. Please check permissions or other issues."
            fi
        else
            echo "User '$username' does not exist."
        fi
    done
}

fn_reset() {
    echo
    read -p "Enter the number of users for which you need to reset the password: " num_users

    if [[ ! "$num_users" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Invalid input. Please enter a positive integer greater than zero."
        exit 1
    fi

    if ! sudo -v; then
        echo "Error: This script requires sudo privileges to reset passwords."
        exit 1
    fi

    for ((i = 1; i <= $num_users; i++)); do
        read -p "Do you know the username for user $i? If yes, press 1: " yes

        if [ $yes -eq 1 ]; then
            read -p "Enter username for user $i to reset the password: " username

            if [[ -z "$username" ]]; then
                echo "Error: Invalid username. Please enter a valid username."
                continue
            fi

            if id "$username" &>/dev/null; then
                read -p "Do you want the new password to be shown on the screen? If yes, press 1: " response

                if [ $response -eq 1 ]; then
                    read -p "Enter new password for user $username: " password
                else
                    read -s -p "Enter new password for user $username: " password
                    echo
                fi

                if [[ ${#password} -ge 8 ]]; then
                    echo "$username:$password" | sudo chpasswd
                    chpasswd_status=$?
                    if [ $chpasswd_status -eq 0 ]; then
                        echo "Password for user '$username' updated successfully."
                    fi
                else
                    echo "Error: Password must be at least 8 characters long."
                fi
            else
                echo "Error: User '$username' does not exist."
            fi
        else
            echo "All Users In System Are Listed Below"
            echo ""
            echo ""
            awk -F":" '{print $1}' /etc/passwd | sed -e 'N;N;N;s/\n/ /g'
            read -p "Enter username from above for user $i to reset the password: " username

            if [[ -z "$username" ]]; then
                echo "Error: Invalid username. Please enter a valid username."
                continue
            fi

            if id "$username" &>/dev/null; then
                read -p "Do you want the new password to be shown on screen,if yes press 1" response
            else
                echo "User '$username' does not exist."
            fi

            if [ $response -eq 1 ]; then
                read -p "Enter new password for user $username: " password
            else
                read -s -p "Enter new password for user $username: " password
                echo
            fi

            if [[ ${#password} -ge 8 ]]; then
                echo "$username:$password" | sudo chpasswd
                chpasswd_status=$?
                if [ $chpasswd_status -eq 0 ]; then
                    echo "Password for user '$username' updated successfully."
                else
                    echo "Error: Password must be at least 8 characters long."
                fi
            fi
        fi
    done
}

fn_list() {
    echo "Listing all user accounts and their all available details:"

    awk -F: 'BEGIN {
        print "--------------------------------------"
    }
    {
        printf "Username: %s\n", $1
        printf "User ID (UID): %s\n", $3
        printf "Group ID (GID): %s\n", $4
        printf "User Info: %s\n", $5
        printf "Home Directory: %s\n", $6
        printf "Shell: %s\n", $7
        print "--------------------------------------"
    }' /etc/passwd
}

fn_modify() {
    echo
    read -p "Enter the number of users to modify: " num_users
    if [[ ! "$num_users" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Invalid input. Please enter a positive integer greater than zero."
        exit 1
    fi

    if ! sudo -v; then
        echo "Error: This script requires sudo privileges to reset passwords."
        exit 1
    fi

    for ((i = 1; i <= $num_users; i++)); do
        read -p "Do you know the username for user $i? If yes, press 1: " yes

        if [ $yes -eq 1 ]; then
            read -p "Enter username for user $i: " username

            if id "$username" &>/dev/null; then
                read -p "Enter the new username (leave empty to keep the same): " new_username
                read -p "Enter the new user ID (leave empty to keep the same): " new_uid
                read -p "Enter the new group ID (leave empty to keep the same): " new_gid
                read -p "Enter the new home directory (leave empty to keep the same): " new_home
                read -p "Enter the new shell (leave empty to keep the same): " new_shell

                if [[ -n "$new_username" ]]; then
                    if [[ ! "$new_username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
                        echo "Error: Invalid username format. Usernames must start with a lowercase letter or underscore, followed by lowercase letters, digits, hyphens, or underscores."
                        continue
                    fi
                    sudo usermod -l "$new_username" "$username"
                    username="$new_username"
                fi

                if [[ -n "$new_uid" ]]; then
                    if ! [[ "$new_uid" =~ ^[0-9]+$ ]]; then
                        echo "Error: New UID must be a valid numeric value."
                    elif id -u "$new_uid" &>/dev/null; then
                        echo "Error: UID '$new_uid' is already assigned to an existing user."
                    else
                        sudo usermod -u "$new_uid" "$username"
                    fi
                fi

                if [[ -n "$new_gid" ]]; then
                    if ! [[ "$new_gid" =~ ^[0-9]+$ ]]; then
                        echo "Error: New GID must be a valid numeric value."
                    elif id -g "$new_gid" &>/dev/null; then
                        echo "Error: GID '$new_gid' is already assigned to an existing group."
                    else
                        sudo usermod -g "$new_gid" "$username"
                    fi
                fi

                if [[ -n "$new_home" ]]; then
                    if [ -d "$new_home" ]; then
                        sudo usermod -d "$new_home" "$username"
                    else
                        echo "Error: The specified home directory '$new_home' does not exist."
                    fi
                fi

                if [[ -n "$new_shell" ]]; then
                    if grep -q "$new_shell" /etc/shells; then
                        sudo usermod -s "$new_shell" "$username"
                    else
                        echo "Error: The specified shell '$new_shell' is not a valid shell."
                    fi
                fi

                echo "User account '$username' modified successfully."
            else
                echo "Error: User '$username' does not exist."
            fi
        else
            echo "Skipping user $i modification."
        fi
    done
}

submenu() {
    echo -ne "
$(blueprint 'USER MANAGEMENT SUBMENU')
$(whiteprint '1) Create Users')
$(greenprint '2) Delete Users')
$(yellowprint '3) Reset Users')
$(cyanprint '4) List Users')
$(blueprint '5) Modify Users')
$(magentaprint '6) Go Back To Main Menu')
$(redprint '0) Exit')
Choose an option:  "
    read -r ans
    case $ans in
    1) fn_useradd ;;
    2) fn_userdel ;;
    3) fn_reset ;;
    4) fn_list ;;
    5) fn_modify ;;
    6) menu ;;
    0) fn_quit ;;
    *) fn_wrong ;;
    esac
}

menu() {
    while true; do
        echo -ne "
$(magentaprint 'WELCOME TO THE HIDDEN MENU')
$(blueprint '1) USER MANAGEMENT') 
$(redprint '0) Exit')
Choose an option:  "
        read -r ans
        case $ans in
        1) submenu ;;
        0) fn_quit ;;
        *) fn_wrong ;;
        esac
    done
}

if [[ "$1" == "" ]]; then
    fn_hidden
    sleep 2s
    menu
else
    while [[ $# -gt 0 ]]; do
        case "$1" in
        -c | --create) fn_useradd ;;
        -d | --delete) fn_userdel ;;
        -r | --reset) fn_reset ;;
        -l | --list) fn_list ;;
        -m | --modify) fn_modify ;;
        -h | --help) fn_use ;;
        *)
            echo "Invalid option: $1"
            fn_use
            exit 1
            ;;
        esac
        shift
    done
fi