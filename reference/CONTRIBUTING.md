# Contributing to db-query-collection

## Ground Truth Rules

1. If a query is canonical, map it to source code (ampscz_mri_ss or my_django_project) in _meta/MANIFEST.yaml.
2. If an example is simplified, label it as non-canonical.
3. Keep one query concern per file whenever possible.
4. Add or update metadata entries for every new query artifact.

## Required Updates in PRs

- Update _meta/MANIFEST.yaml
- Update _meta/DATA_LINEAGE.yaml when dependencies change
- Add validation notes if output shape or semantics changed
- Add deprecation records for replaced entries

## Naming

- IDs: PID###, REF###, IDX###, MV###, TX###
- Prefer snake_case file names and stable paths

## Verification Checklist

- Canonical logic matches source files
- Internal links resolve
- Query type and canonical flag are accurate
