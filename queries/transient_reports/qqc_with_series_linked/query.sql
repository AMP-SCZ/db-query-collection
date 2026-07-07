WITH timepoints AS (
  SELECT 'Baseline' AS timepoint
  UNION ALL
  SELECT 'Followup'
),
subject_timepoints AS (
  SELECT subject.*, tp.timepoint
  FROM qqc_web_subject AS subject
  CROSS JOIN timepoints AS tp
),
subject_timepoints_status AS (
  SELECT
    subject.*,
    CASE
      WHEN subject.timepoint = 'Baseline' THEN subject.baseline_status
      WHEN subject.timepoint = 'Followup' THEN subject.followup_status
    END AS sankey_status
  FROM subject_timepoints AS subject
),
baseline_survey AS (
  SELECT DISTINCT ON (subject_id) *,
    'Baseline' AS timepoint
  FROM qqc_web_survey
  WHERE redcap_event_name LIKE '%%baseline%%'
  ORDER BY subject_id, modified_datetime DESC
),
followup_survey AS (
  SELECT DISTINCT ON (subject_id) *,
    'Followup' AS timepoint
  FROM qqc_web_survey
  WHERE redcap_event_name LIKE '%%month_2_%%'
  ORDER BY subject_id, modified_datetime DESC
),
combined_surveys AS (
  SELECT * FROM baseline_survey
  UNION ALL
  SELECT * FROM followup_survey
),
cleanup_mrizip AS (
  SELECT *
  FROM qqc_web_mrizip
  WHERE 
      most_recent_file IS TRUE AND
      marked_to_ignore IS FALSE AND
      wrong_format = FALSE AND
      filename NOT LIKE '%%MissingDICOMs%%'
),
cleanup_series AS (
  SELECT *
  FROM qqc_web_series
  WHERE most_recent_series IS TRUE AND extra_series_to_be_excluded IS FALSE
)

SELECT 
  site.network_id,
  site.site_code,
  subject.subject_id,
  subject.timepoint,
  subject.sankey_status as sankey_status_raw,
  CASE
   WHEN subject.sankey_status = 'MRI_DATA_FOUND' THEN 'DPACC has MRI data'
   WHEN subject.sankey_status = 'NO_MRI_DATA' THEN 'Not expecting data'
   WHEN subject.sankey_status = 'MARKED_INCORRECT' THEN 'DPACC has MRI data'
   WHEN subject.sankey_status = 'TO_MARK_MISSING' THEN 'Not expecting data'
   WHEN subject.sankey_status = 'CONFIRMED_MISSING' THEN 'Pending data transfer'
   WHEN subject.sankey_status = 'SUSPECTED_MISSING' THEN 'Potentially getting data'
   WHEN subject.sankey_status = 'SUSPECTED_MISSING' THEN 'Potentially getting data'
   WHEN subject.sankey_status = 'INVALID_RUNSHEET' THEN 'Not expecting data'
   ELSE 'Under Investigation'
  END AS sankey_status,
  basicinfo.chrcrit_included,
  basicinfo.recruited,
  basicinfo.cohort,
  basicinfo.subject_removed,
  basicinfo.removed_event,
  basicinfo.withdrawal_status,

  cs.survey_data->>'chrmiss_domain_type___3' AS miss_domain_type,
  cs.survey_data->>'chrmiss_domain_spec' AS miss_domain_spec,
  cs.survey_data->>'chrmiss_time' AS miss_time,
  cs.survey_data->>'chrmiss_time_spec' AS miss_time_spec,
  cs.survey_data->>'chrmiss_withdrawn' AS miss_withdrawn,
  cs.survey_data->>'chrmiss_withdrawn_spec' AS miss_withdrawn_spec,
  cs.survey_data->>'chrmiss_discon' AS miss_discon,
  cs.survey_data->>'chrmiss_discon_spec' AS miss_discon_spec,

  runsheet.data->>'chrmri_missing' AS missing_marked_in_runsheet,
  runsheet.data->>'chrmri_t1_qc' AS t1w_qc,

  runsheet.run_sheet_date,
  mrizip.filename,
  vqcs.qc_summary_score,
  runsheet.missing_added_to_tracker AS missing_notified,
  reupload.reupload_added_to_tracker AS reupload_requested,
  investigate.investigate_added AS investigation_requested,
  mrizip.damanged AS damaged,
  rescan_mrizip.filename AS rescan_filename,
  rescan.note AS rescan_note,
  series.series_number,
  series.series_description,
  series.nifti_path,
  vqc.qc_score

FROM subject_timepoints_status subject
LEFT JOIN qqc_web_site site on site.site_code = subject.site_id
LEFT JOIN qqc_web_mrirunsheet runsheet
  ON runsheet.subject_id = subject.subject_id
  AND runsheet.timepoint = subject.timepoint

/* subject info */
LEFT JOIN qqc_web_basicinfo basicinfo ON subject.subject_id = basicinfo.subject_id
LEFT JOIN combined_surveys cs ON (cs.subject_id = subject.subject_id AND cs.timepoint = subject.timepoint)

LEFT JOIN cleanup_mrizip mrizip ON mrizip.mri_run_sheet_id = runsheet.id
LEFT JOIN qqc_web_qqc qqc ON qqc.mri_zip_id = mrizip.id
LEFT JOIN qqc_web_visualqualitycontrolsummary vqcs ON vqcs.qqc_id = qqc.id

/* rescan */
LEFT JOIN qqc_web_qqcrescan rescan ON rescan.qqc_original_id = qqc.id
LEFT JOIN qqc_web_qqcrescan_qqc_rescan rescans ON rescans.qqcrescan_id = rescan.id
LEFT JOIN qqc_web_qqc rescan_qqc ON rescan_qqc.id = rescans.qqc_id
LEFT JOIN qqc_web_mrizip rescan_mrizip ON rescan_mrizip.id = rescan_qqc.mri_zip_id
LEFT JOIN qqc_web_qqcrescan_qqc_rescan self_rescan ON self_rescan.qqc_id = qqc.id

/* reupload */
LEFT JOIN qqc_web_qqcreupload reupload ON reupload.qqc_id = qqc.id

/* investigate */
LEFT JOIN qqc_web_investigate investigate ON investigate.qqc_id = qqc.id

/* join seires */
LEFT JOIN cleanup_series series ON series.qqc_id = qqc.id
LEFT JOIN qqc_web_visualqualitycontrol vqc ON vqc.series_id = series.id
WHERE (basicinfo.recruited = TRUE and
       self_rescan.qqcrescan_id IS NULL)

