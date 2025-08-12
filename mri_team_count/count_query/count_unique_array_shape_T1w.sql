SELECT 
    mri_team_count_series.site_code,
    series.array_shape,
    COUNT(*) AS shape_count
FROM mri_team_count_series
LEFT JOIN mri.qqc_web_qqc qqc 
    ON mri_team_count_series.qqc_id = qqc.id
LEFT JOIN mri.qqc_web_series series 
    ON mri_team_count_series.series_id = series.id
WHERE
    series.most_recent_series IS TRUE
    AND mri_team_count_series.series_description LIKE '%T2w%'
    AND series.array_shape IS NOT NULL
    AND series.extra_series_to_be_excluded IS NOT TRUE
    AND mri_team_count_series.qc_score IS NOT NULL
GROUP BY
    mri_team_count_series.site_code,
    series.array_shape
ORDER BY
    mri_team_count_series.site_code,
    shape_count DESC;
