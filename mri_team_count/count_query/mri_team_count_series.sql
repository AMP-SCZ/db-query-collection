WITH cleanup_series AS (
  SELECT *
  FROM mri.qqc_web_series
  WHERE most_recent_series IS TRUE AND extra_series_to_be_excluded IS FALSE
)
SELECT 
  mri_team_count.*,
  series.id,
  series.series_number,
  series.series_description,
  series.nifti_path,
  vqc.qc_score

/* merge */
FROM mri.mri_team_count mri_team_count
/* JOIN series */
LEFT JOIN cleanup_series series ON series.qqc_id = mri_team_count.qqc_id
LEFT JOIN mri.qqc_web_visualqualitycontrol vqc ON vqc.series_id = series.id
