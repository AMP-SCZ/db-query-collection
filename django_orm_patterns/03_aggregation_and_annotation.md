---
id: PID003
type: orm_pattern
status: active
canonical: true
source_refs:
    - my_django_project/dmri_harmonization/views.py
    - ampscz_mri_ss/qqc_nda4_summary/report_queries.py
last_verified: 2026-07-07
---

# 03. Aggregation And Annotation

This guide covers Count, Avg, annotate, and grouped values queries.

## Why These Matter

Aggregations power dashboard counts, completeness checks, and status summaries.

## Pattern A: Status counts by group

Example source pattern:

- my_django_project/dmri_harmonization/views.py

```python
status_rows = queryset.values("status").annotate(count=Count("id"))
```

When to use:

- You need grouped totals by categorical field.

Pitfall:

- If you annotate after joins, count inflation can happen unless distinct is used carefully.

## Pattern B: Conditional counts with filter in Count

Example source pattern:

- my_django_project/dmri_harmonization/query_helpers.py

```python
ArtificialSite.objects.annotate(
    hc_unique_subjects=Count(
        "qqcs__subject_id",
        filter=Q(qqcs__subject__basicinfo__cohort__iexact="HC"),
        distinct=True,
    )
)
```

When to use:

- You need multiple conditional metrics in one query.

Pitfall:

- distinct=True can be necessary but expensive on large joins.

## Pattern C: Cohort x site summary table

Example source pattern:

- ampscz_mri_ss/qqc_nda4_summary/report_queries.py

```python
rows = (
    query.filter(subject__basicinfo__cohort__in=["CHR", "HC"])
    .values("subject__site__site_code", "subject__basicinfo__cohort")
    .annotate(subject_count=Count("subject_id", distinct=True))
    .order_by("subject__site__site_code", "subject__basicinfo__cohort")
)
```

When to use:

- You need pivot-like reporting with grouped keys.

Pitfall:

- values keys become long relation paths; keep naming clear in post-processing.

## Pattern D: Completeness checks from metrics table

Example source pattern:

- my_django_project/dmri_harmonization/query_helpers.py

```python
complete_ids = (
    Metric.objects.filter(value_type="post", metric__in=["FA", "FW", "FAt", "MD"])
    .values("application_id")
    .annotate(modality_count=Count("metric", distinct=True))
    .filter(modality_count=4)
    .values_list("application_id", flat=True)
)
```

When to use:

- You define completion based on presence of multiple required categories.

Pitfall:

- Keep required modality list centralized to avoid mismatch with UI.

## Quick Checklist

- Use grouped values plus annotate for report rows.
- Add distinct only when duplicates are possible.
- Prefer DB-side aggregation over Python loops for large tables.
- Keep aggregation keys and labels documented.
