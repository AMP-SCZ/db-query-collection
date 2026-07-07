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
