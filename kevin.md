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
SELECT site.site_code, qqc.manual_check_done AS "DPACC checked", qqc.subject_str, qqc.session_str, demo.gender, demo.age, demo.cohort,
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
  site.site_code, qqc.manual_check_done, qqc.subject_str, qqc.session_str, demo.gender, demo.age, demo.cohort
```
