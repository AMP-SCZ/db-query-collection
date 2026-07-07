---
id: PID001
type: orm_pattern
status: active
canonical: true
source_refs:
    - ampscz_mri_ss/qqc_nda4_summary/common.py:get_final_mrizip_queryset
    - my_django_project/dmri_harmonization/query_helpers.py:DwiHarmonizationQueryMixin
last_verified: 2026-07-07
---

# 01. Filters and Selection

This guide covers the most common query operations:

- `filter`
- `exclude`
- `get` and `first`
- `values` and `values_list`
- `distinct`
- `order_by`

## Why These Matter

Most Django data tasks are selection problems: narrow to the correct rows before joins, annotations, or exports.

## Pattern A: Canonical filtered base queryset

Used to define a reusable cohort of valid rows.

Example source patterns:

- my_django_project/dmri_harmonization/query_helpers.py
- ampscz_mri_ss/qqc_nda4_summary/common.py

```python
qs = MriZip.objects.filter(
    most_recent_file=True,
    marked_to_ignore=False,
    qqc__manual_check_done=True,
    qqc__curated=True,
).exclude(
    qqc__qqc_rescans__isnull=False,
).exclude(
    mri_run_sheet__timepoint__isnull=True,
)
```

When to use:

- You need one canonical base queryset reused across multiple views or reports.

Pitfall:

- If this logic is duplicated across files, filter drift appears over time.

## Pattern B: Batch update with id filter

Used in admin actions and moderation flows.

Example source pattern:

- my_django_project/accounts/admin_views.py

```python
User.objects.filter(id__in=user_ids).update(is_active=True)
```

When to use:

- You need one SQL UPDATE for multiple records.

Pitfall:

- `update()` bypasses model `save()` methods and signals.

## Pattern C: Subject-level ID extraction

Used for reporting or cross-step set logic.

Example source patterns:

- my_django_project/dmri_harmonization/query_helpers.py
- ampscz_mri_ss/qqc_nda4_summary/report_queries.py

```python
subject_ids = qs.values_list("subject_id", flat=True).distinct().order_by("subject_id")
```

When to use:

- You need lightweight ID lists for set operations or CSV exports.

Pitfall:

- `values_list()` is efficient, but if you later need related fields you can create N+1 queries by reloading objects one by one.

## Pattern D: Ordered selection with safe fallback

Often used with first to choose one best row.

Example source patterns:

- my_django_project/dmri_harmonization/views.py
- ampscz_mri_ss/qqc_site_level_summary/extract_site_dwi_summary.py

```python
latest = DwiPreproc.objects.filter(qqc=qqc).order_by("-updated_at", "-created_at").first()
```

When to use:

- You need deterministic picking of one row.

Pitfall:

- Without explicit ordering, `first()` is not deterministic.

## Quick Checklist

- Always define ordering before first.
- Prefer values_list for ID-only extraction.
- Keep canonical filters centralized.
- Use exclude intentionally, especially in multi-join queries.
