# db-query-collection
A centralized collection of SQL queries utilized across the AMP SCZ project.

## Contents
- [mri_team_count](#mri_team_count)

## mri_team_count

This directory contains the SQL query used to create the materialized view `mri_team_count` in the `mri` schema.
The DNA007 server is configured to clone this repository every hour and update the materialized view.
This ensures that everyone counting MR-related data has access to the same number of subjects.
Please ensure to follow the PR process when any updates to the query for the materialized view are needed.

You can access the `mri_team_count` table (materialized view) using the following SQL query:

```sql
SELECT * FROM mri.mri_team_count;
```

The materialized view is directly accessible from the database as well as through DBeaver. It is also saved in the following path:

```
/data/predict1/home/kcho/software/db-query-collection/mri_team_count.csv
```

