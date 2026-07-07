---
id: IDX002
type: index
status: active
canonical: true
source_refs:
	- ../_meta/MANIFEST.yaml
	- ../_meta/DATA_LINEAGE.yaml
last_verified: 2026-07-07
---

# Django ORM Query Collection

Registry ID group: `PID###` and `REF###` (see `_meta/MANIFEST.yaml`).

This folder documents real Django ORM query patterns used across:

- my_django_project
- ampscz_mri_ss

The goal is practical readability: each document explains why the query shape is used, when to use it, and common pitfalls.

## Canonical Rules

- Canonical query contracts must map to source logic in `ampscz_mri_ss` and/or `my_django_project`.
- Conceptual examples are allowed, but should be interpreted as non-canonical unless explicitly marked.
- For exact SQL structure, prefer `08_queryset_sql_snapshots.md` over conceptual translation pages.

Metadata pointers:

- `../_meta/MANIFEST.yaml`
- `../_meta/DATA_LINEAGE.yaml`

## Pattern Guides

1. [01_filters_and_selection.md](01_filters_and_selection.md)
2. [02_relationship_loading.md](02_relationship_loading.md)
3. [03_aggregation_and_annotation.md](03_aggregation_and_annotation.md)
4. [04_conditional_composition.md](04_conditional_composition.md)
5. [05_subqueries_and_advanced.md](05_subqueries_and_advanced.md)
6. [06_harmonization_query_playbook.md](06_harmonization_query_playbook.md)
7. [07_orm_to_sql_cheatsheet.md](07_orm_to_sql_cheatsheet.md)
8. [08_queryset_sql_snapshots.md](08_queryset_sql_snapshots.md)
9. [app_source_map.md](app_source_map.md)

## How To Use This Collection

- Start with 01 and 02 if you are new to Django queries.
- Use 03 through 05 when tuning performance or correctness.
- Use 06 when working on harmonization workflows.
- Use 07 when translating ORM into SQL checks in DBeaver.
- Use 08 when you need exact Django-compiled SQL structure.
- Use app_source_map.md to find query examples by app and file.

Recommended retrieval sequence for LLMs:

1. `06_harmonization_query_playbook.md`
2. `01_filters_and_selection.md`
3. `08_queryset_sql_snapshots.md`
4. `07_orm_to_sql_cheatsheet.md`

## Scope Notes

- Documentation is based on query usage found in Django app code and management commands.
- Query examples are intentionally short and adapted for clarity.
- Raw SQL scripts remain documented at the root of db-query-collection.
