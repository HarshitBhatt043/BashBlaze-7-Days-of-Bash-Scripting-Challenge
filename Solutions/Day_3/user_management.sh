#!/bin/bash

# Define ANSI escape codes for different colors
ESC=$(printf '\033') RESET="${ESC}[0m" BLACK="${ESC}[30m" RED="${ESC}[31m"
GREEN="${ESC}[32m" YELLOW="${ESC}[33m" BLUE="${ESC}[34m" MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m" WHITE="${ESC}[37m" DEFAULT="${ESC}[39m"

# Function to print text in color
whiteprint() { printf "${WHITE}%s${RESET}\n" "$1"; }
greenprint() { printf "${GREEN}%s${RESET}\n" "$1"; }
blueprint() { printf "${BLUE}%s${RESET}\n" "$1"; }
redprint() { printf "${RED}%s${RESET}\n" "$1"; }
yellowprint() { printf "${YELLOW}%s${RESET}\n" "$1"; }
magentaprint() { printf "${MAGENTA}%s${RESET}\n" "$1"; }
cyanprint() { printf "${CYAN}%s${RESET}\n" "$1"; }

# Define a function named fn_hidden
fn_hidden() {
    echo ""
    echo "This is an argument script, You need to supply arguments..."
    echo ""
    # Call another function named fn_use
    fn_use
    # Wait for 6 seconds using sleep command
    sleep 6s
    # Wait for user input and store it in the variable 'hidden'
    read -p "Still want to continue? Press ENTER or type 'quit' to exit: " hidden
    # Check if the variable 'hidden' is empty (user pressed ENTER)
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
    # Check if the user entered 'quit'
    elif [ "$hidden" == "quit" ]; then
        # Call another function named fn_quit
        fn_quit
    else
        # If the user entered an invalid option, display an error message and re-prompt
        echo "Invalid option. Please press ENTER or type 'quit' to exit."
        # Call this function again (recursion) to re-prompt the user
        fn_hidden
    fi
}

# Define a function named fn_use
# This function displays the usage information and available options for the script
fn_use() {
    echo "Usage: $0 [OPTIONS]" # Print the script name (stored in $0) along with "[OPTIONS]"
    echo "Options:"
    echo "  -c, --create  Create a new user account."                        # Display option -c or --create description
    echo "  -d, --delete  Delete an existing user account."                  # Display option -d or --delete description
    echo "  -r, --reset   Reset password for an existing user account."      # Display option -r or --reset description
    echo "  -l, --list    Detailed list of all user accounts on the system." # Display option -l or --list description
    echo "  -m, --modify  Modify user properties"                            # Display option -m or --modify description
    echo "  -h, --help    Show this help message"                            # Display option -h or --help description
}

# Define a function named fn_quit
# This function displays a farewell message and gracefully exits the script
fn_quit() {
    echo "Bye bye." # Print "Bye bye."
    exit 0          # Exit the script with a successful status code (0)
}

# Define a function named fn_wrong
# This function displays an error message for wrong options and exits with an error status
fn_wrong() {
    echo "Wrong option, try again." # Print an error message
    exit 1                          # Exit the script with an error status code (1)
}

# Define a function named fn_useradd
# This function allows the creation of multiple users with specified usernames and passwords
fn_useradd() {
    echo
    read -p "Enter the number of users to create: " num_users # Prompt for the number of users to create

    # Validate if the input is a positive integer greater than zero
    if [[ ! "$num_users" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Invalid input. Please enter a positive integer greater than zero."
        exit 1 # Exit the script with an error status code (1)
    fi

    # Check if sudo privileges are available before proceeding
    if ! sudo -v; then
        echo "Error: This script requires sudo privileges to create users."
        exit 1 # Exit the script with an error status code (1)
    fi

    # Loop to create specified number of users
    for ((i = 1; i <= $num_users; i++)); do
        read -p "Enter username for user $i: " username # Prompt for the username

        # Validate the username format - it must start with a lowercase letter or underscore, followed by lowercase letters, digits, hyphens, or underscores.
        if [[ ! "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
            echo "Error: Invalid username format. Usernames must start with a lowercase letter or underscore, followed by lowercase letters, digits, hyphens, or underscores."
            continue # Skip to the next iteration of the loop if the username is invalid
        fi

        # Check if the user already exists
        if id "$username" &>/dev/null; then
            echo "User '$username' already exists."
        else
            # Prompt for the password with an option to hide it on screen
            read -p "Do you want the password to be shown on screen, if yes press 1: " response

            # Check the response to determine if the password should be shown on screen
            if [ $response -eq 1 ]; then
                read -p "Enter password for user $i: " password
            else
                read -s -p "Enter password for user $i: " password
            fi

            # Check the password length (at least 8 characters) before creating the user
            if [[ ${#password} -ge 8 ]]; then
                # Create the user account using sudo privileges
                sudo useradd -m "$username"
                useradd_status=$?

                # If the user was successfully created, set the password using chpasswd
                if [ $useradd_status -eq 0 ]; then
                    echo "$username:$password" | sudo chpasswd
                    chpasswd_status=$?

                    # Check if the password was set successfully
                    if [ $chpasswd_status -eq 0 ]; then
                        grep -w "^$username" /etc/passwd # Display the user details from /etc/passwd
                        echo "User account $username created successfully!"
                    else
                        echo "Error: Failed to set password for user '$username'."
                        sudo userdel -r "$username" # Rollback user creation if password setting fails
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

# Define a function named fn_userdel
# This function allows the deletion of multiple user accounts
fn_userdel() {
    echo
    read -p "Enter the number of users to delete: " num_users # Prompt for the number of users to delete

    # Validate if the input is a positive integer greater than zero
    if [[ ! "$num_users" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Invalid input. Please enter a positive integer greater than zero."
        exit 1 # Exit the script with an error status code (1)
    fi

    # Check if sudo privileges are available before proceeding
    if ! sudo -v; then
        echo "Error: This script requires sudo privileges to delete users."
        exit 1 # Exit the script with an error status code (1)
    fi

    # Loop to delete specified number of users
    for ((i = 1; i <= $num_users; i++)); do
        read -p "Do you know the username for user $i? If yes, press 1: " yes

        # If the user knows the username (option 1), prompt for the username
        if [ $yes -eq 1 ]; then
            read -p "Enter username for user $i: " username

            # Check if the user exists before deleting it
            if id "$username" &>/dev/null; then
                sudo userdel -r $username # Delete the user account using sudo privileges
                userdel_status=$?

                # Check if the user deletion was successful
                if [ $userdel_status -eq 0 ]; then
                    echo "User account '$username' deleted successfully!"
                else
                    echo "Error: Failed to delete user '$username'. Please check permissions or other issues."
                fi
            else
                echo "User '$username' does not exist."
            fi

        # If the user doesn't know the username, list all users and prompt for the username
        else
            echo "All Users In System Are Listed Below"
            echo ""
            echo ""
            # List all users from /etc/passwd using awk and sed to format the output
            awk -F":" '{print $1}' /etc/passwd | sed -e 'N;N;N;N;s/\n/ /g'
            read -p "Enter username from above for user $i: " username
        fi

        # Validate the entered username
        if [[ -z "$username" ]]; then
            echo "Error: Invalid username. Please enter a valid username."
            continue # Skip to the next iteration of the loop if the username is invalid
        fi

        # Check if the user is attempting to delete the root user (which is not allowed)
        if [[ "$username" == "root" ]]; then
            echo "Error: Cannot delete the root user."
            continue # Skip to the next iteration of the loop if the user tries to delete root
        fi

        # Check if the user exists before attempting to delete it
        if id "$username" &>/dev/null; then
            sudo userdel -r $username # Delete the user account using sudo privileges
            userdel_status=$?

            # Check if the user deletion was successful
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

# Define a function named fn_reset
# This function allows resetting the passwords for multiple user accounts
fn_reset() {
    echo
    read -p "Enter the number of users for which you need to reset the password: " num_users # Prompt for the number of users to reset passwords

    # Validate if the input is a positive integer greater than zero
    if [[ ! "$num_users" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Invalid input. Please enter a positive integer greater than zero."
        exit 1 # Exit the script with an error status code (1)
    fi

    # Check if sudo privileges are available before proceeding
    if ! sudo -v; then
        echo "Error: This script requires sudo privileges to reset passwords."
        exit 1 # Exit the script with an error status code (1)
    fi

    # Loop to reset passwords for specified number of users
    for ((i = 1; i <= $num_users; i++)); do
        read -p "Do you know the username for user $i? If yes, press 1: " yes

        # If the user knows the username (option 1), prompt for the username
        if [ $yes -eq 1 ]; then
            read -p "Enter username for user $i to reset the password: " username

            # Validate the entered username
            if [[ -z "$username" ]]; then
                echo "Error: Invalid username. Please enter a valid username."
                continue # Skip to the next iteration of the loop if the username is invalid
            fi

            # Check if the user exists before resetting the password
            if id "$username" &>/dev/null; then
                # Prompt for the new password with an option to hide it on screen
                read -p "Do you want the new password to be shown on the screen? If yes, press 1: " response

                # Check the response to determine if the new password should be shown on screen
                if [ $response -eq 1 ]; then
                    read -p "Enter new password for user $username: " password
                else
                    read -s -p "Enter new password for user $username: " password
                    echo
                fi

                # Check the password length (at least 8 characters) before updating the password
                if [[ ${#password} -ge 8 ]]; then
                    echo "$username:$password" | sudo chpasswd
                    chpasswd_status=$?

                    # Check if the password update was successful
                    if [ $chpasswd_status -eq 0 ]; then
                        echo "Password for user '$username' updated successfully."
                    fi
                else
                    echo "Error: Password must be at least 8 characters long."
                fi
            else
                echo "Error: User '$username' does not exist."
            fi
        # If the user doesn't know the username, list all users and prompt for the username
        else
            echo "All Users In System Are Listed Below"
            echo ""
            echo ""
            # List all users from /etc/passwd using awk and sed to format the output
            awk -F":" '{print $1}' /etc/passwd | sed -e 'N;N;N;N;s/\n/ /g'
            read -p "Enter username from above for user $i to reset the password: " username

            # Validate the entered username
            if [[ -z "$username" ]]; then
                echo "Error: Invalid username. Please enter a valid username."
                continue # Skip to the next iteration of the loop if the username is invalid
            fi

            # Check if the user exists before resetting the password
            if id "$username" &>/dev/null; then
                read -p "Do you want the new password to be shown on the screen? If yes, press 1: " response
            else
                echo "User '$username' does not exist."
            fi

            # Check the response to determine if the new password should be shown on screen
            if [ $response -eq 1 ]; then
                read -p "Enter new password for user $username: " password
            else
                read -s -p "Enter new password for user $username: " password
                echo
            fi

            # Check the password length (at least 8 characters) before updating the password
            if [[ ${#password} -ge 8 ]]; then
                echo "$username:$password" | sudo chpasswd
                chpasswd_status=$?

                # Check if the password update was successful
                if [ $chpasswd_status -eq 0 ]; then
                    echo "Password for user '$username' updated successfully."
                else
                    echo "Error: Failed to update password for user '$username'. Please check permissions or other issues."
                fi
            fi
        fi
    done
}

# Define a function named fn_list
# This function lists all user accounts on the system along with their details
fn_list() {
    echo "Listing all user accounts and their all available details:"

    # Using awk to format and display user details from /etc/passwd
    awk -F: 'BEGIN {
        print "--------------------------------------"   # Print header separator before listing users
    }
    {
        printf "Username: %s\n", $1   # Print the username
        printf "User ID (UID): %s\n", $3   # Print the User ID (UID)
        printf "Group ID (GID): %s\n", $4   # Print the Group ID (GID)
        printf "User Info: %s\n", $5   # Print the User Info
        printf "Home Directory: %s\n", $6   # Print the Home Directory
        printf "Shell: %s\n", $7   # Print the Shell
        print "--------------------------------------"   # Print separator after each user details
    }' /etc/passwd # Use /etc/passwd file as input to the awk command
}

# Define a function named fn_modify
# This function allows modifying attributes of multiple user accounts
fn_modify() {
    echo
    read -p "Enter the number of users to modify: " num_users # Prompt for the number of users to modify

    # Validate if the input is a positive integer greater than zero
    if [[ ! "$num_users" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Invalid input. Please enter a positive integer greater than zero."
        exit 1 # Exit the script with an error status code (1)
    fi

    # Check if sudo privileges are available before proceeding
    if ! sudo -v; then
        echo "Error: This script requires sudo privileges to modify user accounts."
        exit 1 # Exit the script with an error status code (1)
    fi

    # Loop to modify attributes for specified number of users
    for ((i = 1; i <= $num_users; i++)); do
        read -p "Do you know the username for user $i? If yes, press 1: " yes

        # If the user knows the username (option 1), prompt for the username
        if [ $yes -eq 1 ]; then
            read -p "Enter username for user $i: " username

            # Check if the user exists before modifying its attributes
            if id "$username" &>/dev/null; then
                read -p "Enter the new username (leave empty to keep the same): " new_username
                read -p "Enter the new user ID (leave empty to keep the same): " new_uid
                read -p "Enter the new group ID (leave empty to keep the same): " new_gid
                read -p "Enter the new home directory (leave empty to keep the same): " new_home
                read -p "Enter the new shell (leave empty to keep the same): " new_shell

                # Check and modify the username if specified and valid
                if [[ -n "$new_username" ]]; then
                    if [[ ! "$new_username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
                        echo "Error: Invalid username format. Usernames must start with a lowercase letter or underscore, followed by lowercase letters, digits, hyphens, or underscores."
                        continue # Skip to the next iteration of the loop if the username is invalid
                    fi
                    sudo usermod -l "$new_username" "$username"
                    username="$new_username"
                fi

                # Check and modify the user ID (UID) if specified and valid
                if [[ -n "$new_uid" ]]; then
                    if ! [[ "$new_uid" =~ ^[0-9]+$ ]]; then
                        echo "Error: New UID must be a valid numeric value."
                    elif id -u "$new_uid" &>/dev/null; then
                        echo "Error: UID '$new_uid' is already assigned to an existing user."
                    else
                        sudo usermod -u "$new_uid" "$username"
                    fi
                fi

                # Check and modify the group ID (GID) if specified and valid
                if [[ -n "$new_gid" ]]; then
                    if ! [[ "$new_gid" =~ ^[0-9]+$ ]]; then
                        echo "Error: New GID must be a valid numeric value."
                    elif id -g "$new_gid" &>/dev/null; then
                        echo "Error: GID '$new_gid' is already assigned to an existing group."
                    else
                        sudo usermod -g "$new_gid" "$username"
                    fi
                fi

                # Check and modify the home directory if specified and valid
                if [[ -n "$new_home" ]]; then
                    if [ -d "$new_home" ]; then
                        sudo usermod -d "$new_home" "$username"
                    else
                        echo "Error: The specified home directory '$new_home' does not exist."
                    fi
                fi

                # Check and modify the shell if specified and valid
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

# Function to display the submenu for User Management
submenu() {
    # Print the submenu options with different colors
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

    # Read user input into the variable 'ans'
    read -r ans

    # Evaluate user input using a case statement
    case $ans in
    1) fn_useradd ;; # If the user entered 1, call the function fn_useradd to create users
    2) fn_userdel ;; # If the user entered 2, call the function fn_userdel to delete users
    3) fn_reset ;;   # If the user entered 3, call the function fn_reset to reset users
    4) fn_list ;;    # If the user entered 4, call the function fn_list to list users
    5) fn_modify ;;  # If the user entered 5, call the function fn_modify to modify users
    6) menu ;;       # If the user entered 6, go back to the main menu (function menu)
    0) fn_quit ;;    # If the user entered 0, call the function fn_quit to exit the script
    *) fn_wrong ;;   # If the user entered an invalid option, call the function fn_wrong
    esac
}

# Function to display the main menu
menu() {
    while true; do
        # Print the main menu options with different colors
        echo -ne "
$(magentaprint 'WELCOME TO THE HIDDEN MENU')
$(blueprint '1) USER MANAGEMENT') 
$(redprint '0) Exit')
Choose an option:  "

        # Read user input into the variable 'ans'
        read -r ans

        # Evaluate user input using a case statement
        case $ans in
        1) submenu ;;  # If the user entered 1, go to the submenu for User Management (function submenu)
        0) fn_quit ;;  # If the user entered 0, call the function fn_quit to exit the script
        *) fn_wrong ;; # If the user entered an invalid option, call the function fn_wrong
        esac
    done
}

# Check if there are no command-line arguments
if [[ "$1" == "" ]]; then
    fn_hidden # If no arguments provided, call the function fn_hidden to perform certain actions
    sleep 2s  # Wait for 2 seconds
    menu      # Call the function menu to display the main menu
else
    # Loop through the command-line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
        -c | --create) fn_useradd ;; # If the argument is -c or --create, call the function fn_useradd to create users
        -d | --delete) fn_userdel ;; # If the argument is -d or --delete, call the function fn_userdel to delete users
        -r | --reset) fn_reset ;;    # If the argument is -r or --reset, call the function fn_reset to reset users
        -l | --list) fn_list ;;      # If the argument is -l or --list, call the function fn_list to list users
        -m | --modify) fn_modify ;;  # If the argument is -m or --modify, call the function fn_modify to modify users
        -h | --help) fn_use ;;       # If the argument is -h or --help, call the function fn_use to display help
        *)
            # If an invalid option is provided, print an error message and call the function fn_use to display help
            echo "Invalid option: $1"
            fn_use
            exit 1 # Exit the script with an error status
            ;;
        esac
        shift # Move to the next command-line argument
    done
fi
