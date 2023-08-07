# Bash Process Monitoring and Restart Script

## Description

This Bash script is designed to monitor specified processes, restart them if they're not running, and provide notification options (via email or Slack) for intervention. It ensures critical processes are always operational and notifies administrators in case of failures.

## Usage

1. Ensure you have sudo privileges to execute the script. Run the script using the following command:

   ```
   sudo ./monitor_process.sh <process_name1> <process_name2> ...
   ```

2. Provide the name(s) of the process(es) you want to monitor as command-line arguments.

3. The script will check if the specified process is running. If not, it will attempt to restart it. If the restart fails, notifications will be sent based on your preferences.

## Configuration

1. Update the `config.txt` file with your specific settings before running the script. If the config file is missing or empty, a default config will be downloaded from the provided URL.

2. Configure the following settings in the `config.txt` file:
- Slack webhook URL for notifications (`Webhook`)
- Email settings for notifications (`recipient`, `subject`, `body`)
- Google SMTP server settings (`smtp_server`, `smtp_port`, `username`, `password`)

3. Set the maximum number of restart attempts (`Max_Attempts`) and the sleep duration between attempts (`Sleep`) in the script.

## Notifications
1. The script offers two notification options: Email and Slack. Choose one based on your preference during script execution.

2. If you choose Email notification:

- Configure recipient, subject, and body settings in `config.txt`.
- Ensure Google SMTP server settings are correctly configured.
3. If you choose Slack notification:

- Configure the Slack webhook URL in `config.txt`.
## Considerations
- Ensure the script is executed with sudo privileges to perform process checks and restarts.

- Make sure the necessary dependencies (wget and curl) are installed. The script will attempt to install them if not found.

- The script assumes processes are managed by `systemctl`. Adjust the script if a different process management tool is used.

- Customize error handling messages and actions to suit your environment and requirements.

- Keep your `config.txt` file secure, as it contains sensitive information.

This script is a starting point and may require further customization for specific use cases.

## Automation

1. To schedule the script to run at regular intervals using a cron job :
- You need to know basics of how cron works. 
- Edit the script for a particular notification option and then add this line at the end of your crontab
```
0 2 * * * /path/to/your/script.sh <process_name1> <process_name2> ...
```
- Aother option is to save your input in `input.txt` and send it to script like:
```
0 2 * * * /usr/bin/sh -c "/path/to/your/script.sh <process_name1> <process_name2> ... < input.txt"
```
## Note

The script and documentation provided are intended as a starting point. It is your responsibility to review, understand, and adapt them to your environment and requirements.

