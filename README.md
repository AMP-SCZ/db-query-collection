# db-query-collection
A centralized collection of SQL queries utilized across the AMP SCZ project.

This repository is being refactored as a ground-truth query knowledge base for both humans and LLM-based tooling.

## Contents
- [llm_ground_truth_layer](#llm_ground_truth_layer)
- [mri_team_count](#mri_team_count)
- [django_orm_patterns](#django_orm_patterns)
- [reference_and_governance](#reference_and_governance)
- [github_action](#github_action)

## llm_ground_truth_layer

Start here if you are building tooling or prompting an LLM against this repository:

- [_meta/MANIFEST.yaml](_meta/MANIFEST.yaml) — canonical registry of query artifacts and IDs
- [_meta/SCHEMA.json](_meta/SCHEMA.json) — entry schema contract
- [_meta/DATA_LINEAGE.yaml](_meta/DATA_LINEAGE.yaml) — dependency and downstream mapping
- [_meta/DEPRECATIONS.yaml](_meta/DEPRECATIONS.yaml) — replacement and migration records
- [_meta/GLOSSARY.yaml](_meta/GLOSSARY.yaml) — shared terminology

Ground-truth policy:

- Canonical entries map directly to source logic in `ampscz_mri_ss` and/or `my_django_project`.
- Non-canonical entries are allowed for explanation and exploration but must be labeled.
- Mixed-doc artifacts are tracked in the manifest and are candidates for atomization.

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

LLM retrieval order for ORM docs:

1. `django_orm_patterns/06_harmonization_query_playbook.md` for cross-file contracts
2. `django_orm_patterns/01_filters_and_selection.md` for canonical eligibility filters
3. `django_orm_patterns/08_queryset_sql_snapshots.md` for exact SQL compiler output
4. `django_orm_patterns/07_orm_to_sql_cheatsheet.md` for conceptual SQL translations

## reference_and_governance

- [reference/CONTRIBUTING.md](reference/CONTRIBUTING.md)
- [reference/query_unit_template.md](reference/query_unit_template.md)



## Github action
See `.github/workflows/auto-pr.yml` for the GitHub Action that automatically merges the `mri_team_count` branch into `master`.
