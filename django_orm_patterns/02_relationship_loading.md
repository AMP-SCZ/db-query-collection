---
id: PID002
type: orm_pattern
status: active
canonical: true
source_refs:
    - my_django_project/dmri_harmonization/views.py
    - ampscz_mri_ss/dMRIharmonization/views.py
last_verified: 2026-07-07
---

# 02. Relationship Loading

This guide covers select_related, prefetch_related, and Prefetch.

## Why These Matter

Most performance issues in Django pages come from relationship loading choices.

- select_related loads FK or OneToOne joins in one SQL query.
- prefetch_related loads reverse or many-to-many relations with additional optimized queries.

## Pattern A: select_related for one-to-one and FK chains

Example source patterns:

- my_django_project/dmri_harmonization/query_helpers.py
- ampscz_mri_ss/qqc_site_level_summary/extract_site_dwi_summary.py

```python
queryset = Apply.objects.select_related(
    "template__reference__artificial_site",
    "template__target_site",
    "artificial_site",
    "created_by",
)
```

When to use:

- You will read fields from related FK objects in list rendering.

Pitfall:

- Overly deep select_related can fetch wide rows and increase memory.

## Pattern B: prefetch_related for many-to-many and reverse relations

Example source patterns:

- my_django_project/dmri_harmonization/query_helpers.py
- ampscz_mri_ss/qqc_site_level_summary/extract_site_dwi_summary.py

```python
queryset = Template.objects.prefetch_related(
    "target_sites",
    "ref_qqcs__subject__basicinfo",
    "target_qqcs__subject__basicinfo",
)
```

When to use:

- You need many child rows for each parent row.

Pitfall:

- Prefetching too much without pagination can consume large memory.

## Pattern C: Custom Prefetch queryset

Example source pattern:

- my_django_project/dmri_harmonization/views.py

```python
rescans = QqcRescan.objects.prefetch_related(
    Prefetch(
        "final_series",
        queryset=Series.objects.filter(dwi_pa_filter)
        .select_related("visualqualitycontrol")
        .order_by("-created_at", "-id"),
    )
)
```

When to use:

- You need filtered or ordered related rows instead of all rows.

Pitfall:

- If filter logic differs from main query assumptions, results can look inconsistent.

## Pattern D: Hybrid strategy

Common in report views:

- select_related for single related objects.
- prefetch_related for collections.

Example source patterns:

- my_django_project/dmri_harmonization/query_helpers.py
- ampscz_mri_ss/qqc_site_level_summary/extract_site_dwi_summary.py

## Quick Checklist

- FK or OneToOne: start with select_related.
- Reverse or M2M: start with prefetch_related.
- Keep query load proportional to page size.
- Profile heavy pages before adding more relationships.
