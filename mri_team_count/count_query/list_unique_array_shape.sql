SELECT 
    mri_team_count_series.site_code,
    mri_team_count_series.subject_id,
    mri_team_count_series.timepoint,
    mri_team_count_series.sankey_status_detail,
    mri_team_count_series.qc_score,
    mri_team_count_series.series_number,
    mri_team_count_series.series_description,
    series.array_shape
FROM mri_team_count_series
LEFT JOIN mri.qqc_web_qqc qqc ON mri_team_count_series.qqc_id = qqc.id
LEFT JOIN mri.qqc_web_series series ON mri_team_count_series.series_id = series.id
WHERE
    series.most_recent_series IS TRUE
    AND mri_team_count_series.series_description LIKE '%T1w%'
    AND series.array_shape IS NOT NULL
    AND series.extra_series_to_be_excluded IS NOT TRUE
    AND mri_team_count_series.qc_score IS NOT NULL
