# 1. Stop all running jobs on the Toolforge server.
# This command ensures that any ongoing processes are halted, preventing potential conflicts
# with the new tasks you're about to start. It clears the job queue to make way for fresh jobs.
echo "Stopping all running jobs on the Toolforge server..."
toolforge-jobs flush
echo "All running jobs have been stopped."

# 2. Remove the old repository directory and its contents.
# Before downloading the latest version of your repository, it's crucial to remove the previous 
# version to avoid conflicts or outdated files. This command recursively deletes the repos 
# directory from your home directory.
echo "Removing the old repository directory..."
rm -fdr repos
echo "Old repository directory has been removed."

# 3. Clone the main repository along with its submodules into the specified directory.
# This command downloads the latest version of the repository from GitHub into your home directory.
# The --recurse-submodules flag ensures that all submodules within the repo are also cloned, 
# which is essential for projects that rely on additional modules.
echo "Cloning the main repository along with its submodules..."
git clone --recurse-submodules https://github.com/LokasWiki/LokasBot.git repos
echo "Repository has been cloned."

# 4. Make the setup-venvs.sh script executable.
# This command changes the permissions of the setup-venvs.sh script, making it executable 
# by the user and group. Without this, the script cannot be run, which would prevent the 
# setup of virtual environments or other dependencies.
echo "Making the setup-venvs.sh script executable..."
chmod ug+x repos/toolforge/bin/setup-venvs.sh
echo "Script setup-venvs.sh is now executable."

# 5. Start a Toolforge job to run the setup-venvs script.
# This command initiates a job on the Toolforge server to execute the setup-venvs.sh script 
# within a Python 3.9 environment. This step is critical for setting up the virtual 
# environments required by your project.
echo "Starting a Toolforge job to run the setup-venvs script..."
toolforge-jobs run setup-venvs --command repos/toolforge/bin/setup-venvs.sh --image tf-python39
echo "Toolforge job for setup-venvs has been started."

# 6. Display the logs of the setup-venvs job in real-time.
# By following the log file with tail -f and monitoring for the specific end message,
# you can view the progress and output of the setup-venvs job. This is useful for debugging 
# or ensuring that the setup completes successfully. The command will stop automatically
# once the end message "end setup lokas-bot-scripts" is found in the logs.
echo "Displaying logs of the setup-venvs job..."
tail -f setup-venvs.* | awk '/end setup lokas-bot-scripts/ {exit}'

# 7. Set read, write, and execute permissions for the user and group on all files in the repos directory.
# This command ensures that all files and directories within the repos directory have the 
# necessary permissions for execution. This is important for scripts that will be run later on.
echo "Setting permissions for all files in the repos directory..."
chmod -R ug+x repos/*
echo "Permissions have been set."

# 8. Copy the user's configuration files into the repository directory.
# These commands copy essential configuration and authentication files (like user-config.py 
# and user-password.py) into the repository. These files are necessary for the bot's operation, 
# allowing it to authenticate and function correctly.
echo "Copying configuration files into the repository directory..."
cp user-config.py  repos
cp user-password.py repos
echo "Configuration files have been copied."

# 9. Load Toolforge cron jobs from the specified YAML file.
# The load command reads the cronjobs1.yaml file, which contains the schedule and 
# specifications for the jobs that need to be run on the Toolforge server. This step 
# is critical for automating tasks on a predefined schedule.
echo "Loading Toolforge cron jobs from the YAML file..."
toolforge-jobs load repos/toolforge/cronjobs1.yaml
echo "Cron jobs have been loaded."

# 10. Run a test job to verify that the code was pulled successfully.
# This command tests the setup by executing a test-pull.sh script, ensuring that the 
# code was pulled and set up correctly. The --wait flag makes the command synchronous, 
# meaning the script will wait for the job to complete before proceeding. This is useful 
# for immediate feedback and validation.
echo "Running a test job to verify the code was pulled successfully..."
toolforge-jobs run script --command repos/toolforge/jobs/ci_cd_log_task.sh --image tf-python39 --wait
echo "Test job has completed."


