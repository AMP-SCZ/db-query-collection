#!/bin/bash

# 0 * * * * /data/predict1/home/kcho/software/db-query-collection/mri_team_count/update_and_run_mri_team_count.sh

# Navigate to the repository directory
cd /data/predict1/home/kcho/software/db-query-collection || exit

# Pull the latest changes from the master branch
git pull origin mri_team_count

# Execute the Python script to create the MRI team count view
/data/pnl/kcho/miniforge3/bin/python mri_team_count/create_mri_team_count_view.py
