SELECT subject_id, timepoint, cohort, qc_score, series_description
FROM mri_team_count_series
WHERE (
    -- Include descriptions containing 'T1w' (case-insensitive)
    LOWER(series_description) LIKE '%t1w%'
    
    -- Include descriptions containing 'b0' (case-insensitive)
    OR LOWER(series_description) LIKE '%b0%'
    
    -- Include descriptions containing 'dMRI_dir'
    OR LOWER(series_description) LIKE '%dmri_dir%'
)
-- Exclude any descriptions containing these terms (case-insensitive)
AND LOWER(series_description) NOT LIKE '%sbref%'
AND LOWER(series_description) NOT LIKE '%fa%'
AND LOWER(series_description) NOT LIKE '%vwip%'
AND LOWER(series_description) NOT LIKE '%copy%'
AND LOWER(series_description) NOT LIKE '%adjust%'
AND LOWER(series_description) NOT LIKE '%eyes%';
