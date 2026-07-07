---
id: PID004
type: orm_pattern
status: active
canonical: true
source_refs:
    - my_django_project/dmri_harmonization/views.py
    - my_django_project/dmri_harmonization/query_helpers.py
last_verified: 2026-07-07
---

# 04. Conditional Composition

This guide covers Q objects, composable filters, and queryset union.

## Why These Matter

Real workflows often need dynamic conditions that cannot be expressed in a single fixed filter call.

## Pattern A: Boolean logic with Q

Example source patterns:

- my_django_project/dmri_harmonization/query_helpers.py
- my_django_project/qqc_web/views.py

```python
finished_filter = (Q(status="completed") | Q(completed=True)) & Q(failed=False)
```

When to use:

- You need OR plus AND in the same expression.

Pitfall:

- Parentheses matter. Incorrect grouping changes meaning.

## Pattern B: Dynamic OR accumulation

Example source pattern:

- my_django_project/qqc_web/test_qqc_module.py

```python
filter_query = Q()
for series_number, series_description in duplicated_series_tuples:
    filter_query |= Q(
        series__series_number=series_number,
        series__series_description=series_description,
    )
rows = Qqc.objects.filter(filter_query).distinct()
```

When to use:

- Condition list is data-driven and only known at runtime.

Pitfall:

- Very large OR chains can produce heavy SQL. Consider chunking or temporary tables when needed.

## Pattern C: Queryset union for merged result sets

Example source patterns:

- my_django_project/dmri_harmonization/query_helpers.py
- ampscz_mri_ss/dMRIharmonization/views.py

```python
all_harmonized_ids = completed_ids_from_apply.union(completed_ids_from_dwi)
```

When to use:

- You need unique combined rows from two compatible querysets.

Pitfall:

- Union requires compatible selected columns and types.

## Pattern D: Multi-step composition for readability

Example source pattern:

- ampscz_mri_ss/qqc_nda4_summary/report_queries.py

Strategy:

1. Create a base queryset.
2. Derive cohort subsets.
3. Apply repeated helper functions for counts and IDs.

This reduces duplication and keeps report definitions auditable.

## Quick Checklist

- Use Q for explicit boolean logic.
- Build dynamic query expressions incrementally.
- Use union when two querysets represent equivalent entities.
- Prefer helper functions for repeated composition patterns.
