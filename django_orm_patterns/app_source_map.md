# App Source Map

This index maps Django apps to representative query-heavy files documented in this collection.

## my_django_project

### accounts

- my_django_project/accounts/admin_views.py
  - filter and bulk update patterns for user approval flows.

### dmri_harmonization

- my_django_project/dmri_harmonization/query_helpers.py
- my_django_project/dmri_harmonization/views.py
- my_django_project/dmri_harmonization/management/commands/initialize_dmri_harmonization.py
- my_django_project/dmri_harmonization/management/commands/import_dmri_harmonization_templates.py
- my_django_project/dmri_harmonization/management/commands/reconcile_multi_target_templates.py
- my_django_project/dmri_harmonization/management/commands/sync_apply_status.py
- my_django_project/dmri_harmonization/management/commands/sync_template_status.py
- my_django_project/dmri_harmonization/management/commands/load_tbss_metrics.py

### qqc_web

- my_django_project/qqc_web/views.py
- my_django_project/qqc_web/series_module.py
- my_django_project/qqc_web/core/subject_module.py
- my_django_project/qqc_web/management/commands/curate_one_qqc.py
- my_django_project/qqc_web/management/commands/rerun_phoenix_session.py
- my_django_project/qqc_web/management/commands/scan_and_run_zip_to_qqc_nonphoenix.py

### schedule

- my_django_project/schedule/views.py
  - generic class-based views with model-backed list and detail access.

### pages

- my_django_project/pages/views.py
  - mostly template rendering; minimal direct ORM usage.

## ampscz_mri_ss

### dMRIharmonization

- ampscz_mri_ss/dMRIharmonization/dwi_session_query.py
- ampscz_mri_ss/dMRIharmonization/views.py
- ampscz_mri_ss/dMRIharmonization/management/commands/harmonization_scan_progress.py
- ampscz_mri_ss/dMRIharmonization/management/commands/harmonization_build_symlinks.py

### qqc_nda4_summary

- ampscz_mri_ss/qqc_nda4_summary/common.py
- ampscz_mri_ss/qqc_nda4_summary/report_queries.py
- ampscz_mri_ss/qqc_nda4_summary/views.py

### qqc_site_level_summary

- ampscz_mri_ss/qqc_site_level_summary/extract_site_dwi_summary.py
- ampscz_mri_ss/qqc_site_level_summary/extract_site_qqc_summary.py
- ampscz_mri_ss/qqc_site_level_summary/extract_site_dwi_html_report.py

### qqc_web

- ampscz_mri_ss/qqc_web/models.py
- ampscz_mri_ss/qqc_web/management/commands/mriqc_import_dry_run.py

### ampscz_ehr

- ampscz_mri_ss/ampscz_ehr/models.py
  - model definitions and supporting data structures used by query scripts.

### investigating_mri_missingness

- ampscz_mri_ss/investigating_mri_missingness/build_missingness_outputs.py
- ampscz_mri_ss/investigating_mri_missingness/inspect_subject_missingness.py

## Notes

- This map focuses on practical query logic and query-heavy modules.
- Legacy and archived scripts in ampscz_mri_ss/examples and qqc_nda4_summary/legacy also contain many additional query examples.
