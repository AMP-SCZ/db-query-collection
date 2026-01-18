SELECT
  q.subject_id,
  s.json_data ->> 'SoftwareVersions' AS software_versions
FROM qqc_web_qqc q
JOIN qqc_web_series s
  ON s.qqc_id = q.id
WHERE s.most_recent_series = TRUE
  AND s.series_description ILIKE '%dMRI%'
  AND s.series_description ILIKE '%PA%'
  AND s.series_description NOT ILIKE '%sbref%'
  AND NULLIF(s.json_data ->> 'SoftwareVersions', '') IS NOT NULL
  AND q.subject_id IN (
    SELECT q2.subject_id
    FROM qqc_web_qqc q2
    JOIN qqc_web_series s2
      ON s2.qqc_id = q2.id
    WHERE s2.most_recent_series = TRUE
      AND s2.series_description ILIKE '%dMRI%'
      AND s2.series_description ILIKE '%PA%'
      AND s2.series_description NOT ILIKE '%sbref%'
      AND NULLIF(s2.json_data ->> 'SoftwareVersions', '') IS NOT NULL
    GROUP BY q2.subject_id
    HAVING COUNT(DISTINCT s2.json_data ->> 'SoftwareVersions') >= 2
  )
GROUP BY q.subject_id, software_versions
ORDER BY q.subject_id, software_versions;
