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

- Query classification is explicit; canonical or non-canonical is stated, and rationale is included.
- Placement follows repository structure; the query is added to the correct folder and naming convention is respected.
- Manifest entry is updated; _meta/MANIFEST.yaml includes id, type, path, canonical flag, and source reference when canonical.
- Lineage is updated when dependencies change; _meta/DATA_LINEAGE.yaml reflects any added or changed upstream/downstream dependencies.
- Deprecation is recorded when replacing or removing entries; _meta/DEPRECATIONS.yaml includes replacement id and migration note.
- Canonical proof is included; PR description cites authoritative source location and explains how logic matches.
- Validation is run and reported; validation/check_metadata.sh output is included in the PR.
- Navigation/docs are kept in sync; any affected index/reference pages are updated so links remain discoverable.
- Scope is clean; PR excludes unrelated operational files (for example large logs or lockfile churn) unless intentionally part of the change.