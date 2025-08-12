WITH cleanup_series AS (
    SELECT *
    FROM mri.mri_team_count_series mri_team_count_series
    WHERE
        mri_team_count_series.series_description ILIKE '%%dmri%%' AND
        mri_team_count_series.series_description LIKE '%%PA%%' AND
        mri_team_count_series.series_description NOT ILIKE '%%sbref%%' AND
        mri_team_count_series.series_description NOT ILIKE '%%_fa%%' AND
        mri_team_count_series.series_description NOT ILIKE '%%_colfa%%'
),
most_recent_dwi AS (
      SELECT DISTINCT ON (qqc_id) *
      FROM mri.qqc_web_dwipreproc
      ORDER BY qqc_id, updated_at DESC
)
SELECT *
FROM cleanup_series series
LEFT JOIN most_recent_dwi dwi ON series.qqc_id = dwi.qqc_id
WHERE dwi.from_curated_dwi IS TRUE
