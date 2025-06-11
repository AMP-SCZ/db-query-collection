# Extracting Missing Data Reasons for All Recruited Subjects Across Baseline and Followup Timepoints

This SQL query is designed to generate a comprehensive table that lists, for every recruited subject, whether there are any documented reasons for missing data at both the Baseline and Followup study timepoints. It combines subject and timepoint data to ensure every recruited subject appears once for each of the two critical study timepoints, regardless of whether missing data has been recorded.


Key Steps:

1. Create Timepoints:
The query first defines two study timepoints: 'Baseline' and 'Followup'.

2. Expand Subjects by Timepoint:
Every subject is paired with both timepoints, ensuring that each subject has a row for both Baseline and Followup, even if there is no corresponding missing data entry.

3. Extract Missing Data Forms:
Two subqueries pull out missing data form responses from the REDCap-derived forms, one for Baseline events and one for Followup (month 2) events. These include specific fields describing why data may be missing, such as withdrawal, discontinuation, or domain-specific reasons.

4. Combine Everything:
Using a series of LEFT JOINs, each subject-timepoint combination is joined to the relevant missing data form.

- The COALESCE function is used to pick the available value from either the baseline or followup missing data forms, based on the current timepoint.

- Only subjects flagged as recruited in the recruitment status table are included.


```sql
WITH timepoints AS (
  SELECT 'Baseline' AS timepoint
  UNION ALL
  SELECT 'Followup'
),
subject_timepoints AS (
  SELECT subject.id as subject_id, tp.timepoint
  FROM subjects AS subject
  CROSS JOIN timepoints AS tp
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
)
SELECT
    subject_timepoints.subject_id,
    subject_timepoints.timepoint,
    COALESCE(baseline_missing.event_name, followup_missing.event_name) as event_name,
    COALESCE(baseline_missing.chrmiss_time, followup_missing.chrmiss_time) as chrmiss_time,
    COALESCE(baseline_missing.chrmiss_time_spec, followup_missing.chrmiss_time_spec) as chrmiss_time_spec,
    COALESCE(baseline_missing.chrmiss_domain, followup_missing.chrmiss_domain) as chrmiss_domain,
    COALESCE(baseline_missing.chrmiss_domain_type, followup_missing.chrmiss_domain_type) as chrmiss_domain_type,
    COALESCE(baseline_missing.chrmiss_domain_spec, followup_missing.chrmiss_domain_spec) as chrmiss_domain_spec,
    COALESCE(baseline_missing.chrmiss_withdrawn, followup_missing.chrmiss_withdrawn) as chrmiss_withdrawn,
    COALESCE(baseline_missing.chrmiss_withdrawn_spec, followup_missing.chrmiss_withdrawn_spec) as chrmiss_withdrawn_spec,
    COALESCE(baseline_missing.chrmiss_discon, followup_missing.chrmiss_discon) as chrmiss_discon,
    COALESCE(baseline_missing.chrmiss_discon_spec, followup_missing.chrmiss_discon_spec) as chrmiss_discon_spec
FROM subject_timepoints
LEFT JOIN baseline_missing ON subject_timepoints.subject_id = baseline_missing.subject_id AND subject_timepoints.timepoint = 'Baseline'
LEFT JOIN followup_missing ON subject_timepoints.subject_id = followup_missing.subject_id AND subject_timepoints.timepoint = 'Followup'
LEFT JOIN forms_derived.recruitment_status rs on rs.subject_id = subject_timepoints.subject_id
WHERE rs.recruited IS TRUE

```
