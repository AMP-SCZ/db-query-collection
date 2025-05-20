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






