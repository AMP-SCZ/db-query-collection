---
id: REF002
type: snapshot
status: active
canonical: true
source_refs:
	- my_django_project/dmri_harmonization/query_helpers.py
	- ampscz_mri_ss/qqc_nda4_summary/common.py:get_final_mrizip_queryset
last_verified: 2026-07-07
---

# 08. Exact QuerySet SQL Snapshots

This page captures exact `str(queryset.query)` output for critical query shapes.

Important:

- This is Django compiler output, not fully parameter-substituted SQL.
- Some values are shown as placeholders or unquoted tokens in the string form.
- Use this for structure validation, joins, and where-clause inspection.

## Snapshot 1: canonical_mrizip_base (my_django_project)

Source pattern:

- dmri_harmonization.query_helpers.DwiHarmonizationQueryMixin._qqc_dwi_queryset

```sql
SELECT "qqc_web_mrizip"."id", "qqc_web_mrizip"."created_at", "qqc_web_mrizip"."updated_at", "qqc_web_mrizip"."most_recent_file", "qqc_web_mrizip"."retransfer", "qqc_web_mrizip"."subject_id", "qqc_web_mrizip"."filepath", "qqc_web_mrizip"."filename", "qqc_web_mrizip"."session_date", "qqc_web_mrizip"."session_date_new", "qqc_web_mrizip"."session_num", "qqc_web_mrizip"."modified_time", "qqc_web_mrizip"."size", "qqc_web_mrizip"."wrong_format", "qqc_web_mrizip"."marked_to_ignore", "qqc_web_mrizip"."wrong_subject", "qqc_web_mrizip"."duplicated_data", "qqc_web_mrizip"."duplicated_data_different_subject", "qqc_web_mrizip"."note", "qqc_web_mrizip"."note_by_id", "qqc_web_mrizip"."has_run_sheet", "qqc_web_mrizip"."unzip_completed", "qqc_web_mrizip"."damanged", "qqc_web_mrizip"."non_dicom_files_in_zip", "qqc_web_mrizip"."qqc_error", "qqc_web_mrizip"."removed", "qqc_web_mrizip"."decompressed", "qqc_web_mrizip"."mri_run_sheet_id", "qqc_web_mrizip"."ra_assigned_id" FROM "qqc_web_mrizip" INNER JOIN "qqc_web_qqc" ON ("qqc_web_mrizip"."id" = "qqc_web_qqc"."mri_zip_id") INNER JOIN "qqc_web_mrirunsheet" ON ("qqc_web_mrizip"."mri_run_sheet_id" = "qqc_web_mrirunsheet"."id") WHERE (NOT "qqc_web_mrizip"."marked_to_ignore" AND "qqc_web_mrizip"."most_recent_file" AND "qqc_web_qqc"."curated" AND "qqc_web_qqc"."manual_check_done" AND NOT (EXISTS(SELECT 1 AS "a" FROM "qqc_web_qqcrescan_qqc_rescan" U2 WHERE (U2."qqcrescan_id" IS NOT NULL AND U2."qqc_id" = ("qqc_web_qqc"."id")) LIMIT 1)) AND NOT ("qqc_web_mrirunsheet"."timepoint" IS NULL))
```

## Snapshot 2: apply_finished_filter (my_django_project)

Source pattern:

- (Q(status="completed") | Q(completed=True)) & Q(failed=False)

```sql
SELECT "dmriharm_apply"."id", "dmriharm_apply"."artificial_site_id", "dmriharm_apply"."template_id", "dmriharm_apply"."qqc_id", "dmriharm_apply"."dwi_id", "dmriharm_apply"."input_dir", "dmriharm_apply"."output_dir", "dmriharm_apply"."input_fa_path", "dmriharm_apply"."input_md_path", "dmriharm_apply"."input_fw_path", "dmriharm_apply"."input_fat_path", "dmriharm_apply"."fa_path", "dmriharm_apply"."md_path", "dmriharm_apply"."fw_path", "dmriharm_apply"."fat_path", "dmriharm_apply"."tbss_dir", "dmriharm_apply"."tbss_fa_csv", "dmriharm_apply"."tbss_md_csv", "dmriharm_apply"."tbss_fw_csv", "dmriharm_apply"."tbss_fat_csv", "dmriharm_apply"."log_path", "dmriharm_apply"."command", "dmriharm_apply"."software_version", "dmriharm_apply"."run_meta", "dmriharm_apply"."status", "dmriharm_apply"."completed", "dmriharm_apply"."completed_at", "dmriharm_apply"."failed", "dmriharm_apply"."error_message", "dmriharm_apply"."created_by_id", "dmriharm_apply"."notes", "dmriharm_apply"."created_at", "dmriharm_apply"."updated_at" FROM "dmriharm_apply" INNER JOIN "dmriharm_template" ON ("dmriharm_apply"."template_id" = "dmriharm_template"."id") INNER JOIN "dmriharm_reference" ON ("dmriharm_template"."reference_id" = "dmriharm_reference"."id") LEFT OUTER JOIN "dmriharm_artificial_site" ON ("dmriharm_template"."target_site_id" = "dmriharm_artificial_site"."id") INNER JOIN "dmriharm_artificial_site" T5 ON ("dmriharm_apply"."artificial_site_id" = T5."id") WHERE (("dmriharm_apply"."status" = completed OR "dmriharm_apply"."completed") AND NOT "dmriharm_apply"."failed") ORDER BY "dmriharm_reference"."name" ASC, "dmriharm_artificial_site"."name" ASC, "dmriharm_template"."name" ASC, T5."name" ASC, "dmriharm_apply"."created_at" ASC
```

## Snapshot 3: apply_status_count (my_django_project)

Source pattern:

- Apply.objects.values("status").annotate(count=Count("id"))

```sql
SELECT "dmriharm_apply"."status", COUNT("dmriharm_apply"."id") AS "count" FROM "dmriharm_apply" INNER JOIN "dmriharm_template" ON ("dmriharm_apply"."template_id" = "dmriharm_template"."id") INNER JOIN "dmriharm_reference" ON ("dmriharm_template"."reference_id" = "dmriharm_reference"."id") LEFT OUTER JOIN "dmriharm_artificial_site" ON ("dmriharm_template"."target_site_id" = "dmriharm_artificial_site"."id") INNER JOIN "dmriharm_artificial_site" T5 ON ("dmriharm_apply"."artificial_site_id" = T5."id") GROUP BY "dmriharm_apply"."status"
```

## Snapshot 4: subquery_valid_dwi_mrizip (my_django_project)

Source pattern:

- MriZip filtered by Subquery(valid_dwi_qqc_ids)

```sql
SELECT "qqc_web_mrizip"."id", "qqc_web_mrizip"."created_at", "qqc_web_mrizip"."updated_at", "qqc_web_mrizip"."most_recent_file", "qqc_web_mrizip"."retransfer", "qqc_web_mrizip"."subject_id", "qqc_web_mrizip"."filepath", "qqc_web_mrizip"."filename", "qqc_web_mrizip"."session_date", "qqc_web_mrizip"."session_date_new", "qqc_web_mrizip"."session_num", "qqc_web_mrizip"."modified_time", "qqc_web_mrizip"."size", "qqc_web_mrizip"."wrong_format", "qqc_web_mrizip"."marked_to_ignore", "qqc_web_mrizip"."wrong_subject", "qqc_web_mrizip"."duplicated_data", "qqc_web_mrizip"."duplicated_data_different_subject", "qqc_web_mrizip"."note", "qqc_web_mrizip"."note_by_id", "qqc_web_mrizip"."has_run_sheet", "qqc_web_mrizip"."unzip_completed", "qqc_web_mrizip"."damanged", "qqc_web_mrizip"."non_dicom_files_in_zip", "qqc_web_mrizip"."qqc_error", "qqc_web_mrizip"."removed", "qqc_web_mrizip"."decompressed", "qqc_web_mrizip"."mri_run_sheet_id", "qqc_web_mrizip"."ra_assigned_id" FROM "qqc_web_mrizip" INNER JOIN "qqc_web_qqc" ON ("qqc_web_mrizip"."id" = "qqc_web_qqc"."mri_zip_id") INNER JOIN "qqc_web_mrirunsheet" ON ("qqc_web_mrizip"."mri_run_sheet_id" = "qqc_web_mrirunsheet"."id") WHERE (NOT "qqc_web_mrizip"."marked_to_ignore" AND "qqc_web_mrizip"."most_recent_file" AND "qqc_web_qqc"."curated" AND "qqc_web_qqc"."id" IN (SELECT DISTINCT U0."qqc_id" FROM "qqc_web_series" U0 WHERE (NOT U0."extra_series_to_be_excluded" AND U0."most_recent_series" AND UPPER(U0."series_description"::text) LIKE UPPER(%dMRI%) AND NOT (UPPER(U0."series_description"::text) LIKE UPPER(%sbref%) AND U0."series_description" IS NOT NULL) AND NOT (U0."series_number" = 0 AND U0."series_number" IS NOT NULL))) AND "qqc_web_qqc"."manual_check_done" AND NOT (EXISTS(SELECT 1 AS "a" FROM "qqc_web_qqcrescan_qqc_rescan" U2 WHERE (U2."qqcrescan_id" IS NOT NULL AND U2."qqc_id" = ("qqc_web_qqc"."id")) LIMIT 1)) AND NOT ("qqc_web_mrirunsheet"."timepoint" IS NULL))
```

## Snapshot 5: ampscz_final_mrizip (ampscz_mri_ss)

Source pattern:

- qqc_nda4_summary.common.get_final_mrizip_queryset

```sql
SELECT "qqc_web_mrizip"."id", "qqc_web_mrizip"."created_at", "qqc_web_mrizip"."updated_at", "qqc_web_mrizip"."most_recent_file", "qqc_web_mrizip"."retransfer", "qqc_web_mrizip"."subject_id", "qqc_web_mrizip"."filepath", "qqc_web_mrizip"."filename", "qqc_web_mrizip"."session_date", "qqc_web_mrizip"."session_date_new", "qqc_web_mrizip"."session_num", "qqc_web_mrizip"."modified_time", "qqc_web_mrizip"."size", "qqc_web_mrizip"."wrong_format", "qqc_web_mrizip"."marked_to_ignore", "qqc_web_mrizip"."wrong_subject", "qqc_web_mrizip"."duplicated_data", "qqc_web_mrizip"."duplicated_data_different_subject", "qqc_web_mrizip"."note", "qqc_web_mrizip"."note_by_id", "qqc_web_mrizip"."has_run_sheet", "qqc_web_mrizip"."unzip_completed", "qqc_web_mrizip"."damanged", "qqc_web_mrizip"."non_dicom_files_in_zip", "qqc_web_mrizip"."qqc_error", "qqc_web_mrizip"."removed", "qqc_web_mrizip"."decompressed", "qqc_web_mrizip"."mri_run_sheet_id", "qqc_web_mrizip"."ra_assigned_id" FROM "qqc_web_mrizip" INNER JOIN "qqc_web_qqc" ON ("qqc_web_mrizip"."id" = "qqc_web_qqc"."mri_zip_id") INNER JOIN "qqc_web_mrirunsheet" ON ("qqc_web_mrizip"."mri_run_sheet_id" = "qqc_web_mrirunsheet"."id") WHERE (NOT "qqc_web_mrizip"."marked_to_ignore" AND "qqc_web_mrizip"."most_recent_file" AND "qqc_web_qqc"."curated" AND "qqc_web_qqc"."manual_check_done" AND NOT (EXISTS(SELECT 1 AS "a" FROM "qqc_web_qqcrescan_qqc_rescan" U2 WHERE (U2."qqcrescan_id" IS NOT NULL AND U2."qqc_id" = ("qqc_web_qqc"."id")) LIMIT 1)) AND NOT ("qqc_web_mrirunsheet"."timepoint" IS NULL))
```
