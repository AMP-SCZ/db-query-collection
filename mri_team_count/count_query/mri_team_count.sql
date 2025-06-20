WITH timepoints AS (
  SELECT 'Baseline' AS timepoint
  UNION ALL
  SELECT 'Followup'
),
subject_timepoints AS (
  SELECT
    db_subject.id as subject_id,
    subject_qqc.site_id as site_id,
    CASE
      WHEN tp.timepoint = 'Baseline' THEN subject_qqc.baseline_status
      WHEN tp.timepoint = 'Followup' THEN subject_qqc.followup_status
    END AS sankey_status,
    tp.timepoint,
    rs.recruited,
    filters.consent_date,
    filters.gender,
    filters.age,
    filters.cohort,
    filters.chrcrit_included,
    sr.removed,
    sr.removed_date,
    sr.removed_event,
    sr.removed_reason,
    sr.withdrawal_status,
    sr.removed_info_source,
    svs.timepoint as visit_status
  FROM subjects db_subject
  LEFT JOIN mri.qqc_web_subject subject_qqc ON subject_qqc.subject_id=db_subject.id
  LEFT JOIN forms_derived.recruitment_status rs on rs.subject_id=db_subject.id
  LEFT JOIN forms_derived.filters filters on filters.subject=db_subject.id
  LEFT JOIN forms_derived.subject_removed sr on sr.subject_id=db_subject.id
  LEFT JOIN forms_derived.subject_visit_status svs on svs.subject_id=db_subject.id
  CROSS JOIN timepoints AS tp
  WHERE rs.recruited = TRUE
),
baseline_runsheet AS (
  SELECT 
    subject_id,
    percent_complete,
    forms.form_data->>'RAComments' as RAComments,
    forms.form_data->>'chrmri_comments' as chrmri_comments,
    forms.form_data->>'chrmri_addcomment' as chrmri_addcomment
  FROM forms.forms forms
  WHERE
      (forms.form_name LIKE '%%mri_run_sheet%%' AND
       forms.event_name LIKE 'baseline%%')
),
followup_runsheet AS (
  SELECT 
    subject_id,
    percent_complete,
    forms.form_data->>'RAComments' as RAComments,
    forms.form_data->>'chrmri_comments' as chrmri_comments,
    forms.form_data->>'chrmri_addcomment' as chrmri_addcomment
  FROM forms.forms forms
  WHERE
      (forms.form_name LIKE '%%mri_run_sheet%%' AND
       forms.event_name LIKE 'month_2_arm%%')
),
baseline_missing AS (
    SELECT 
        forms.subject_id,
        forms.event_name as event_name,
        forms.form_data->>'chrmiss_time' as chrmiss_time,
        forms.form_data->>'chrmiss_time_spec' as chrmiss_time_spec,
        forms.form_data->>'chrmiss_domain' as chrmiss_domain,
        forms.form_data->>'chrmiss_domain_type___3' as chrmiss_domain_type,
        forms.form_data->>'chrmiss_domain_spec' as chrmiss_domain_spec,
        forms.form_data->>'chrmiss_withdrawn' as chrmiss_withdrawn,
        forms.form_data->>'chrmiss_withdrawn_spec' as chrmiss_withdrawn_spec,
        forms.form_data->>'chrmiss_discon' as chrmiss_discon,
        forms.form_data->>'chrmiss_discon_spec' as chrmiss_discon_spec,
        forms.form_data->>'chrmiss_comments' as chrmiss_comments,
        forms.form_data as data

    FROM forms.forms forms
    WHERE 
        forms.form_name = 'missing_data' AND
        forms.event_name LIKE 'baseline%%'
 ),
followup_missing AS (
    SELECT 
        forms.subject_id,
        forms.event_name as event_name,
        forms.form_data->>'chrmiss_time' as chrmiss_time,
        forms.form_data->>'chrmiss_time_spec' as chrmiss_time_spec,
        forms.form_data->>'chrmiss_domain' as chrmiss_domain,
        forms.form_data->>'chrmiss_domain_type___3' as chrmiss_domain_type,
        forms.form_data->>'chrmiss_domain_spec' as chrmiss_domain_spec,
        forms.form_data->>'chrmiss_withdrawn' as chrmiss_withdrawn,
        forms.form_data->>'chrmiss_withdrawn_spec' as chrmiss_withdrawn_spec,
        forms.form_data->>'chrmiss_discon' as chrmiss_discon,
        forms.form_data->>'chrmiss_discon_spec' as chrmiss_discon_spec,
        forms.form_data->>'chrmiss_comments' as chrmiss_comments,
        forms.form_data as data

    FROM forms.forms forms
    WHERE 
        forms.form_name = 'missing_data' AND
        forms.event_name LIKE 'month_2_arm%%'
),
cleanup_mrizip AS (
  SELECT *
  FROM mri.qqc_web_mrizip
  WHERE 
      most_recent_file IS TRUE AND
      marked_to_ignore IS FALSE AND
      wrong_format = FALSE AND
      filename NOT LIKE '%%MissingDICOMs%%'
),
alt_investigate AS (
    SELECT
      subject_id,
      string_agg(investigate_reason, ';') AS investigate_reason,
      string_agg(investigate_request_added_date::text, ';') AS investigate_request_added_date,
      string_agg(investigate_request_added_by, ';') AS investigate_request_added_by,
      string_agg(investigate_site_contacted::text, ';') AS investigate_site_contacted,
      string_agg(investigate_site_contacted_date::text, ';') AS investigate_site_contacted_date,
      bool_or(investigate_issue_resolved) AS investigate_issue_resolved,
      string_agg(investigate_result, ';') AS investigate_result,
      string_agg(investigate_note, ';') AS investigate_note,
      string_agg(created_at::text, ';') AS created_at,
      string_agg(updated_at::text, ';') AS updated_at,
      string_agg(investigate_session, ';') AS investigate_session,
      string_agg(investigate_added::text, ';') AS investigate_added,
      string_agg(qqc_id::text, ';') AS qqc_id
    FROM mri.qqc_web_investigate
    WHERE (subject_id IS NOT NULL AND investigate_issue_resolved IS FALSE)
    GROUP BY subject_id
)
SELECT 
  site.network_id,
  site.site_code,
  subject.subject_id,
  subject.timepoint,
  subject.sankey_status,
  CASE
   WHEN subject.sankey_status = 'MRI_DATA_FOUND' AND reupload.reupload_issue_resolved = FALSE AND investigate.investigate_issue_resolved = FALSE THEN 'DPACC has MRI data with pending reupload and investigation issues'
   WHEN subject.sankey_status = 'MRI_DATA_FOUND' AND reupload.reupload_issue_resolved = FALSE AND alt_investigate.investigate_issue_resolved = FALSE THEN 'DPACC has MRI data with pending reupload and investigation issues'
   WHEN subject.sankey_status = 'MRI_DATA_FOUND' AND investigate.investigate_issue_resolved = FALSE THEN 'DPACC has MRI data with pending investigation issues in baseline or follow-up for this subject'
   WHEN subject.sankey_status = 'MRI_DATA_FOUND' AND alt_investigate.investigate_issue_resolved = FALSE THEN 'DPACC has MRI data with pending investigation issues in baseline or follow-up for this subject'
   WHEN subject.sankey_status = 'MRI_DATA_FOUND' AND reupload.reupload_issue_resolved = FALSE THEN 'DPACC has MRI data with pending reupload issues'
   WHEN subject.sankey_status = 'MRI_DATA_FOUND' THEN 'DPACC has MRI data'
   WHEN subject.sankey_status = 'NO_MRI_DATA' THEN 'Not expecting data'
   WHEN subject.sankey_status = 'MARKED_INCORRECT' AND alt_investigate.investigate_issue_resolved = FALSE THEN 'DPACC has MRI data but for baseline or follow-up timepoint the subject is under investigation for possible incorrect marking'
   WHEN subject.sankey_status = 'MARKED_INCORRECT' AND investigate.investigate_issue_resolved = FALSE THEN 'DPACC has MRI data but for baseline or follow-up timepoint the subject is under investigation for possible incorrect marking'
   WHEN subject.sankey_status = 'MARKED_INCORRECT' AND reupload.reupload_issue_resolved = FALSE THEN 'DPACC has MRI data but marked incorrectly and/or requires reupload'
   WHEN subject.sankey_status = 'MARKED_INCORRECT' THEN 'DPACC has MRI data'
   WHEN subject.sankey_status = 'TO_MARK_MISSING' THEN 'Not expecting data, please mark as missing on run sheet'
   WHEN subject.sankey_status = 'CONFIRMED_MISSING' THEN 'A valid run sheet indicates a scan occurred, but no data file is present or there is a date discrepancy between zipfile name and runsheet'
   WHEN subject.sankey_status = 'PENDING_DATA' THEN 'Potentially getting data'
   WHEN subject.sankey_status = 'INVALID_RUNSHEET' AND reupload.reupload_issue_resolved = FALSE THEN 'DPACC has MRI data but is under investigation for name or reupload'
   WHEN subject.sankey_status = 'INVALID_RUNSHEET' AND investigate.investigate_issue_resolved = FALSE THEN 'DPACC has MRI data but is under investigation with invalid runsheet'
   WHEN subject.sankey_status = 'INVALID_RUNSHEET' AND alt_investigate.investigate_issue_resolved = FALSE THEN 'DPACC has MRI data but is under investigation with invalid runsheet'
   WHEN subject.sankey_status = 'INVALID_RUNSHEET' THEN 'DPACC has MRI data'
   WHEN subject.sankey_status = 'BEFORE_TIMEPOINT' AND investigate.investigate_issue_resolved = FALSE THEN 'Participant has not reached baseline or followup, and for either the baseline or follow-up timepoint is under investigation'
   WHEN subject.sankey_status = 'BEFORE_TIMEPOINT' AND alt_investigate.investigate_issue_resolved = FALSE THEN 'Participant has not reached baseline or followup and for either the baseline or follow-up timepoint is under investigation'
   WHEN subject.sankey_status = 'BEFORE_TIMEPOINT' THEN 'Participant has not reached baseline or followup'
   WHEN subject.sankey_status = 'SUSPECTED_MISSING' AND investigate.investigate_issue_resolved = FALSE THEN 'DPACC potentially getting data but for baseline or follow-up timepoint the subject is under investigation'
   WHEN subject.sankey_status = 'SUSPECTED_MISSING' AND alt_investigate.investigate_issue_resolved = FALSE THEN 'DPACC potentially getting data but for baseline or follow-up timepoint the subject is under investigation'
   WHEN subject.sankey_status = 'SUSPECTED_MISSING' THEN 'Potentially getting data'
   ELSE 'Under Investigation'
  END AS sankey_status_detail,
  chrcrit_included,
  recruited,
  consent_date
  gender,
  age,
  cohort,
  subject.removed,
  removed_event,
  withdrawal_status,
  visit_status,

  COALESCE(baseline_missing.event_name, followup_missing.event_name) as event_name,
  COALESCE(baseline_missing.chrmiss_time, followup_missing.chrmiss_time) as chrmiss_time,
  COALESCE(baseline_missing.chrmiss_time_spec, followup_missing.chrmiss_time_spec) as chrmiss_time_spec,
  COALESCE(baseline_missing.chrmiss_domain, followup_missing.chrmiss_domain) as chrmiss_domain,
  COALESCE(baseline_missing.chrmiss_domain_type, followup_missing.chrmiss_domain_type) as chrmiss_domain_type,
  COALESCE(baseline_missing.chrmiss_domain_spec, followup_missing.chrmiss_domain_spec) as chrmiss_domain_spec,
  COALESCE(baseline_missing.chrmiss_withdrawn, followup_missing.chrmiss_withdrawn) as chrmiss_withdrawn,
  COALESCE(baseline_missing.chrmiss_withdrawn_spec, followup_missing.chrmiss_withdrawn_spec) as chrmiss_withdrawn_spec,
  COALESCE(baseline_missing.chrmiss_discon, followup_missing.chrmiss_discon) as chrmiss_discon,
  COALESCE(baseline_missing.chrmiss_discon_spec, followup_missing.chrmiss_discon_spec) as chrmiss_discon_spec,
  COALESCE(baseline_missing.chrmiss_comments, followup_missing.chrmiss_comments) as chrmiss_comments,
  COALESCE(baseline_runsheet.percent_complete, followup_runsheet.percent_complete) as run_sheet_percent_complete,
  COALESCE(baseline_runsheet.RAComments, followup_runsheet.RAComments) as run_sheet_RAComments,
  COALESCE(baseline_runsheet.chrmri_comments, followup_runsheet.chrmri_comments) as run_sheet_chrmri_comments,
  COALESCE(baseline_runsheet.chrmri_addcomment, followup_runsheet.chrmri_addcomment) as run_sheet_chrmri_addcomment,

  runsheet.data->>'chrmri_missing' AS missing_marked_in_runsheet,
  runsheet.data->>'chrmri_t1_qc' AS t1w_qc,
  runsheet.data->>'chrmri_missing_spec' as missing_spec,
  runsheet.data->>'chrmri_addcomments' as chrmri_addcomments,
  runsheet.data->>'RAComments' as RAComments,
  runsheet.data->>'chrmri_comments' as chrmri_comments,
  runsheet.data->>'chrmri_addcomment' as chrmri_addcomment,
  runsheet.data as runsheet_data,
  runsheet.run_sheet_date,

  mrizip.filename,
  vqcs.qc_summary_score,
  runsheet.missing_added_to_tracker AS missing_notified,

  reupload.reupload_issue_resolved AS reupload_issue_resolved,
  reupload.reupload_note AS reupload_note,

  COALESCE(investigate.investigate_issue_resolved, alt_investigate.investigate_issue_resolved) as investigate_issue_resolved,
  COALESCE(investigate.investigate_result, alt_investigate.investigate_result) as investigation_issue,
  COALESCE(investigate.investigate_session, alt_investigate.investigate_session) as investigate_session,

  mrizip.damanged AS damaged,
  rescan_mrizip.filename AS rescan_filename,
  rescan.note AS rescan_note,
  qqc.id AS qqc_id

/* merge */
FROM subject_timepoints subject
LEFT JOIN mri.qqc_web_site site on site.site_code = subject.site_id

/* forms data */
LEFT JOIN baseline_missing ON (
    subject.subject_id = baseline_missing.subject_id AND
    subject.timepoint = 'Baseline')
LEFT JOIN followup_missing ON (
    subject.subject_id = followup_missing.subject_id AND
    subject.timepoint = 'Followup')
LEFT JOIN baseline_runsheet ON (
    subject.subject_id = baseline_runsheet.subject_id AND
    subject.timepoint = 'Baseline')
LEFT JOIN followup_runsheet ON (
    subject.subject_id = followup_runsheet.subject_id AND
    subject.timepoint = 'Followup')

/* run sheet in QQC */
LEFT JOIN mri.qqc_web_mrirunsheet runsheet
  ON runsheet.subject_id = subject.subject_id
  AND runsheet.timepoint = subject.timepoint

LEFT JOIN cleanup_mrizip mrizip ON mrizip.mri_run_sheet_id = runsheet.id
LEFT JOIN mri.qqc_web_qqc qqc ON qqc.mri_zip_id = mrizip.id
LEFT JOIN mri.qqc_web_visualqualitycontrolsummary vqcs ON vqcs.qqc_id = qqc.id

/* rescan */
LEFT JOIN mri.qqc_web_qqcrescan rescan ON rescan.qqc_original_id = qqc.id
LEFT JOIN mri.qqc_web_qqcrescan_qqc_rescan rescans ON rescans.qqcrescan_id = rescan.id
LEFT JOIN mri.qqc_web_qqc rescan_qqc ON rescan_qqc.id = rescans.qqc_id
LEFT JOIN mri.qqc_web_mrizip rescan_mrizip ON rescan_mrizip.id = rescan_qqc.mri_zip_id
LEFT JOIN mri.qqc_web_qqcrescan_qqc_rescan self_rescan ON self_rescan.qqc_id = qqc.id

/* reupload */
LEFT JOIN mri.qqc_web_qqcreupload reupload ON reupload.qqc_id = qqc.id

/* investigate */
LEFT JOIN mri.qqc_web_investigate investigate ON investigate.qqc_id = qqc.id
LEFT JOIN alt_investigate alt_investigate ON
    (alt_investigate.subject_id = subject.subject_id AND
     investigate.qqc_id IS NULL)
      
WHERE 
    subject.recruited = TRUE
    AND self_rescan.qqcrescan_id IS NULL
