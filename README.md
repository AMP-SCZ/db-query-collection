# db-query-collection
A centralized collection of SQL queries utilized across the AMP SCZ project.

## Contents
- [mri_team_count](#mri_team_count)
- [django_orm_patterns](#django_orm_patterns)
- [github_action](#github_action)

## mri_team_count

This directory contains the SQL query used to create the materialized view `mri_team_count` in the `mri` schema.

The materialized view provides two rows for each recruited subject, representing baseline and month 2 MRI data,
along with various characteristics and status for each timepoint. AMP-SCZ members counting MRI data should use
this materialized view for deriving harmonized counts from the database.

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


## django_orm_patterns

This directory documents Django ORM query patterns used in both:

- my_django_project
- ampscz_mri_ss

Start here:

- [django_orm_patterns/index.md](django_orm_patterns/index.md)

The guide is organized by pattern so query behavior is easy to understand and compare:

- Filtering and selection
- Relationship loading (select_related, prefetch_related)
- Aggregation and annotation
- Conditional composition with Q and union
- Subquery and advanced patterns (Subquery, OuterRef, Exists)
- Harmonization query playbook
- ORM-to-SQL cheatsheet
- Exact QuerySet SQL snapshots
- App source map



## Github action
See `.github/workflows/auto-pr.yml` for the GitHub Action that automatically merges the `mri_team_count` branch into `master`.
