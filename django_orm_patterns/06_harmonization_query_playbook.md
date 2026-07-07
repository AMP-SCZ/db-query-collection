---
id: PID006
type: orm_pattern
status: active
canonical: true
source_refs:
   - my_django_project/dmri_harmonization/query_helpers.py
   - my_django_project/dmri_harmonization/views.py
   - ampscz_mri_ss/qqc_nda4_summary/common.py
last_verified: 2026-07-07
---

# 06. Harmonization Query Playbook

This playbook explains how harmonization-related query layers fit together.

## Primary Query Flow

1. Canonical DWI session base selection
   - my_django_project/dmri_harmonization/query_helpers.py
   - ampscz_mri_ss/qqc_nda4_summary/common.py
2. Template and apply query shaping
   - my_django_project/dmri_harmonization/query_helpers.py
   - my_django_project/dmri_harmonization/views.py
3. Initialization and template import matching
   - my_django_project/dmri_harmonization/management/commands/initialize_dmri_harmonization.py
   - my_django_project/dmri_harmonization/management/commands/import_dmri_harmonization_templates.py
4. Status sync and completion checks
   - my_django_project/dmri_harmonization/management/commands/sync_template_status.py
   - my_django_project/dmri_harmonization/management/commands/sync_apply_status.py

## Core Query Contracts

### Contract A: Canonical session eligibility

Use the same base constraints whenever possible:

- most_recent_file=True
- marked_to_ignore=False
- qqc manually checked and curated
- no rescans
- valid timepoint

This appears in both repositories and keeps reports aligned.

### Contract B: Harmonization completion identity

In my_django_project, harmonization completion can come from:

- Apply linked directly to qqc_id
- Apply linked through dwi__qqc_id

These are merged with union to avoid missing valid completed sessions.

### Contract C: Template and site assignments

Template selection logic includes:

- target_site and target_sites relationships
- scanner-group sibling matching
- bootstrap template cleanup rules

These rules are implemented in view and command logic and should stay consistent.

## Recommended Query Safety Rules

1. Keep canonical base filters centralized.
2. Prefer query helper methods over repeating long filters.
3. Use Subquery for multi-valued join safety.
4. Use deterministic ordering before first or distinct-on.
5. Validate counts before and after changing query logic.

## High-Value Files For Harmonization Query Work

- my_django_project/dmri_harmonization/query_helpers.py
- my_django_project/dmri_harmonization/views.py
- my_django_project/dmri_harmonization/management/commands/initialize_dmri_harmonization.py
- my_django_project/dmri_harmonization/management/commands/import_dmri_harmonization_templates.py
- my_django_project/dmri_harmonization/management/commands/reconcile_multi_target_templates.py
- my_django_project/dmri_harmonization/management/commands/sync_apply_status.py
- ampscz_mri_ss/dMRIharmonization/dwi_session_query.py
- ampscz_mri_ss/qqc_nda4_summary/common.py
