#!/bin/bash

# 0 * * * * /path/to/update_and_run_mri_team_count.sh

# Navigate to the repository directory
cd /path/to/your/repo || exit

# Pull the latest changes from the master branch
git pull origin mri_team_count

# Execute the Python script to create the MRI team count view
python3 mri_team_count/count_query/create_mri_team_count_view.py
