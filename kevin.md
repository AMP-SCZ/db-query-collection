# Summary of QQC Records with Reupload, Investigation, Damage, and Rescan Status

Comprehensive query to retrieve the latest MRI session details and related quality control, reupload, investigation, damage, and rescan information excluding rescans themselves.

```sql
WITH baseline_survey AS (
  SELECT DISTINCT ON (subject_id) *,
    'Baseline' AS timepoint
  FROM qqc_web_survey
  WHERE redcap_event_name LIKE '%baseline%'
  ORDER BY subject_id, modified_datetime DESC
),

followup_survey AS (
  SELECT DISTINCT ON (subject_id) *,
    'Followup' AS timepoint
  FROM qqc_web_survey
  WHERE redcap_event_name LIKE '%month_2_%'
  ORDER BY subject_id, modified_datetime DESC
),

-- Combined baseline + follow-up surveys
combined_surveys AS (
  SELECT * FROM baseline_survey
  UNION ALL
  SELECT * FROM followup_survey
)

SELECT 
  runsheet.subject_id,
  basicinfo.chrcrit_included,
  basicinfo.recruited,
  basicinfo.cohort,
  basicinfo.subject_removed,
  basicinfo.removed_event,
  basicinfo.withdrawal_status,
  
  cs.survey_data,
  
  runsheet.data->>'chrmri_missing' as missing_marked_in_runsheet,
  
  runsheet.data->>'chrmri_t1_qc' as t1w_qc,
  runsheet.run_sheet_date,
  runsheet.timepoint,
  mrizip.filename,
  vqcs.qc_summary_score,
  runsheet.missing_added_to_tracker as missing_notified,
  reupload.reupload_added_to_tracker as reupload_requested,
  investigate.investigate_added as investigation_requested,
  mrizip.damanged as damaged,
  rescan_mrizip.filename as rescan_filename,
  rescan.note as rescan_note,
  self_rescan.qqcrescan_id

FROM qqc_web_mrirunsheet runsheet
LEFT JOIN qqc_web_mrizip mrizip ON mrizip.mri_run_sheet_id = runsheet.id
LEFT JOIN qqc_web_qqc qqc ON qqc.mri_zip_id = mrizip.id
LEFT JOIN qqc_web_visualqualitycontrolsummary vqcs ON vqcs.qqc_id = qqc.id

/* rescan */
LEFT JOIN qqc_web_qqcrescan rescan ON rescan.qqc_original_id = qqc.id
LEFT JOIN qqc_web_qqcrescan_qqc_rescan rescans ON rescans.qqcrescan_id = rescan.id
LEFT JOIN qqc_web_qqc rescan_qqc ON rescan_qqc.id = rescans.qqc_id
LEFT JOIN qqc_web_mrizip rescan_mrizip ON rescan_mrizip.id = rescan_qqc.mri_zip_id
LEFT JOIN qqc_web_qqcrescan_qqc_rescan self_rescan ON self_rescan.qqc_id = qqc.id

/* missing scan -> included in the run sheet */
/* reupload */
LEFT JOIN qqc_web_qqcreupload reupload ON reupload.qqc_id = qqc.id

/* investigate */
LEFT JOIN qqc_web_investigate investigate ON investigate.qqc_id = qqc.id

/* subject info */
LEFT JOIN qqc_web_basicinfo basicinfo ON runsheet.subject_id = basicinfo.subject_id
LEFT JOIN combined_surveys cs ON (cs.subject_id = runsheet.subject_id AND cs.timepoint = runsheet.timepoint)

WHERE
  (
    mrizip.filename IS NULL
    AND runsheet.run_sheet_date IS NOT NULL
    AND runsheet.data->>'chrmri_t1_qc' ~ '^\d+(\.\d+)?$' 
    AND (runsheet.data->>'chrmri_t1_qc')::float IN (1, 2, 3)
  )
  OR 
  (mrizip.most_recent_file IS TRUE AND
   mrizip.marked_to_ignore IS FALSE AND
  
    /* remove rescans from the table */
    self_rescan.qqcrescan_id IS NULL)
```


# Subjects with Extra Series in NDA Round 3 (Included Sessions Only)

This query identifies subjects and sessions from NDA release round 3 that are marked as included and have at least one extra series flagged for exclusion. It counts the number of such extra series per session, considering only the most recent MRI zip and most recent series records.

```sql
SELECT 
  qqc.subject_str,
  qqc.session_str,
  ndaprep.round_number AS NDA_release,
  ndaprep.included,
  ndaprep.curated,
  COUNT(*) FILTER (WHERE series.extra_series_to_be_excluded = TRUE) AS "Number of extra series detected"
FROM qqc_web_qqc qqc
LEFT JOIN qqc_web_mrizip mrizip ON mrizip.id = qqc.mri_zip_id
LEFT JOIN qqc_web_ndaprep ndaprep ON ndaprep.qqc_id = qqc.id
LEFT JOIN qqc_web_series series ON series.qqc_id = qqc.id
WHERE 
  mrizip.most_recent_file IS TRUE AND
  mrizip.damanged IS FALSE AND
  ndaprep.round_number = 3 AND
  series.most_recent_series IS TRUE AND
  ndaprep.included IS TRUE
GROUP BY 
  qqc.subject_str, 
  qqc.session_str, 
  ndaprep.round_number, 
  ndaprep.included,
  ndaprep.curated
HAVING 
  COUNT(*) FILTER (WHERE series.extra_series_to_be_excluded = TRUE) > 0;
```



# For harmonization

## Summary of B0 and DWI Series Counts and QC Scores per Session


This query summarizes dMRI QC score per subject session by joining quality control (QQC), MRI metadata, demographic, and series-level QC tables. It calculates:
- The number of B0 and DWI series detected,
- The mean QC scores for B0 and DWI series for each session, grouped by site code, subject ID, and session ID. Filters ensure only the most recent, valid MRI files and series are included.


```sql
SELECT site.site_code, qqc.subject_str, qqc.session_str, demo.gender, demo.age, demo.cohort,
  COUNT(*) FILTER (WHERE series.nifti_path LIKE '%_b0_%') AS "Number of b0 detected",
  COUNT(*) FILTER (WHERE series.series_description LIKE '%PA%') AS "Number of DWI detected",
  AVG(vqc.qc_score) FILTER (
    WHERE series.nifti_path LIKE '%_b0_%'
  ) AS "Mean b0 Qc score",
  AVG(vqc.qc_score) FILTER (
    WHERE series.series_description LIKE '%PA%'
  ) AS "Mean DWI Qc score"
FROM qqc_web_qqc qqc
left join qqc_web_mrizip mrizip on mrizip.id = qqc.mri_zip_id
left join qqc_web_subject subject on qqc.subject_id = subject.subject_id
left join qqc_web_site site on site.site_code = subject.site_id
left join qqc_web_basicinfo demo on demo.subject_id = subject.subject_id
left join qqc_web_series series on series.qqc_id = qqc.id
left join qqc_web_visualqualitycontrol vqc ON vqc.series_id = series.id
WHERE
  mrizip.most_recent_file IS TRUE AND
  mrizip.damanged IS FALSE AND
  mrizip.marked_to_ignore IS FALSE AND
  series.most_recent_series IS TRUE AND
  series.extra_series_to_be_excluded IS FALSE AND
  series.nifti_path NOT LIKE '%ref%' AND
  series.nifti_path LIKE '%dwi%'
GROUP BY
  site.site_code, qqc.subject_str, qqc.session_str, demo.gender, demo.age, demo.cohort
```


## Adding acquisition protocol information from jsons

```sql
SELECT site.site_code, qqc.manual_check_done AS "DPACC checked",
  qqc.subject_str, qqc.session_str,
  rs.timepoint,
  demo.gender, demo.age, demo.cohort, 
  COUNT(*) FILTER (WHERE series.nifti_path LIKE '%_b0_%') AS "Number of b0 detected",
  COUNT(*) FILTER (WHERE series.series_description LIKE '%PA%') AS "Number of DWI detected",
  AVG(vqc.qc_score) FILTER (
    WHERE series.nifti_path LIKE '%_b0_%'
  ) AS "Mean b0 Qc score",
  AVG(vqc.qc_score) FILTER (
    WHERE series.series_description LIKE '%PA%'
  ) AS "Mean DWI Qc score",
  AVG(series.max_value) FILTER (
    WHERE series.nifti_path LIKE '%_b0_%'
  ) AS "Average Max value in b0",
  AVG(series.max_value) FILTER (
    WHERE series.series_description LIKE '%PA%'
  ) AS "Average Max value in DWI",
  jsonb_agg(DISTINCT series.array_shape) FILTER (
    WHERE series.nifti_path LIKE '%_b0_%'
  ) AS "Unique B0 array shape",
  jsonb_agg(DISTINCT series.array_shape) FILTER (
    WHERE series.series_description LIKE '%PA%'
  ) AS "Unique DWI array shape",
  jsonb_agg(DISTINCT series.json_data) FILTER (
    WHERE series.nifti_path LIKE '%_b0_%'
  ) AS "Unique B0 json_data",
  jsonb_agg(DISTINCT series.json_data) FILTER (
    WHERE series.series_description LIKE '%PA%'
  ) AS "Unique DWI json_data"
FROM qqc_web_qqc qqc
left join qqc_web_mrizip mrizip on mrizip.id = qqc.mri_zip_id
left join qqc_web_mrirunsheet rs on mrizip.mri_run_sheet_id = rs.id
left join qqc_web_subject subject on qqc.subject_id = subject.subject_id
left join qqc_web_site site on site.site_code = subject.site_id
left join qqc_web_basicinfo demo on demo.subject_id = subject.subject_id
left join qqc_web_series series on series.qqc_id = qqc.id
left join qqc_web_visualqualitycontrol vqc ON vqc.series_id = series.id
WHERE
  mrizip.most_recent_file IS TRUE AND
  mrizip.damanged IS FALSE AND
  mrizip.marked_to_ignore IS FALSE AND
  series.most_recent_series IS TRUE AND
  series.extra_series_to_be_excluded IS FALSE AND
  series.nifti_path NOT LIKE '%ref%' AND
  series.nifti_path LIKE '%dwi%'
GROUP BY
  site.site_code, qqc.manual_check_done, rs.timepoint, qqc.subject_str, qqc.session_str, demo.gender, demo.age, demo.cohort
```
