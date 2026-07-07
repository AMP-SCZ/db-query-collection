# 05. Subqueries And Advanced Patterns

This guide covers Subquery, OuterRef, Exists, and advanced selection decisions.

## Why These Matter

These patterns solve correctness issues that appear with multi-valued joins and latest-row logic.

## Pattern A: Subquery to avoid multi-valued join traps

Example source pattern:

- my_django_project/dmri_harmonization/management/commands/initialize_dmri_harmonization.py

```python
valid_dwi_qqc_ids = (
    Series.objects.filter(
        series_description__icontains="dMRI",
        extra_series_to_be_excluded=False,
        most_recent_series=True,
    )
    .exclude(series_description__icontains="sbref")
    .exclude(series_number="0")
    .values("qqc_id")
    .distinct()
)

qs = MriZip.objects.filter(qqc__in=Subquery(valid_dwi_qqc_ids))
```

When to use:

- A direct join plus exclude could incorrectly drop valid parent rows.

Pitfall:

- Subquery can be expensive without indexes on join keys.

## Pattern B: Latest related row per parent with OuterRef

Example source patterns:

- my_django_project/qqc_web/views.py
- my_django_project/qqc_web/series_module.py

```python
latest_series_subquery = series_queryset.filter(
    series_number=OuterRef("series_number"),
    series_description=OuterRef("series_description"),
).order_by("-first_dicom_modified").values("id")[:1]

series_queryset = series_queryset.filter(id__in=Subquery(latest_series_subquery))
```

When to use:

- You need one representative related row by ordering criterion.

Pitfall:

- Always define deterministic ordering fields.

## Pattern C: Exists-based flags

Example source pattern:

- ampscz_mri_ss/qqc_nda4_summary/report_queries.py

```python
qs = qs.annotate(
    has_t1w=Exists(t1w_subquery),
    has_t2w=Exists(t2w_subquery),
)
```

When to use:

- You need fast boolean existence checks without pulling related rows.

Pitfall:

- Ensure subquery is selective and indexed.

## Pattern D: Distinct-on style selection (PostgreSQL)

Example source pattern:

- my_django_project/dmri_harmonization/management/commands/import_dmri_harmonization_templates.py

```python
dwi_qs = (
    DwiPreproc.objects.filter(qqc_id__in=qqc_ids)
    .order_by("qqc_id", "-most_recent_output", "-updated_at", "-pk")
    .distinct("qqc_id")
)
```

When to use:

- PostgreSQL environment where one row per key is required.

Pitfall:

- distinct(field) is PostgreSQL-specific behavior.

## Quick Checklist

- Use Subquery when direct joins can over-filter parents.
- Use OuterRef for per-parent latest-row selection.
- Use Exists for boolean presence flags.
- Confirm index support on key relation fields.
