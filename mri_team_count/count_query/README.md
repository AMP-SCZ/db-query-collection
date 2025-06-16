# MRI Data Status Query

This query extracts detailed information about MRI scan status, recruitment, missing data, QC status, and rescan/reupload issues for each subject and timepoint in a longitudinal neuroimaging study. It integrates data across subject tracking tables, REDCap-derived form data, and internal QC pipelines.

---

## 📄 Overview

This query builds a subject-timepoint table (`Baseline`, `Followup`) and joins it with multiple data sources to determine the current status of each subject's MRI scan, including:

* Recruitment and demographic info
* Missing data forms
* MRI run sheet completion
* Investigation and reupload status
* QC summary
* Final status mapping for dashboard visualizations (e.g., Sankey plots)

---

## 🗃️ Source Tables

| Table Name                            | Description                                 |
| ------------------------------------- | ------------------------------------------- |
| `subjects`                            | Core subject registry                       |
| `qqc_web_subject`                     | Timepoint-specific status annotations       |
| `forms.forms`                         | REDCap form data (run sheets, missing data) |
| `forms_derived.filters`               | Demographic and inclusion flags             |
| `forms_derived.recruitment_status`    | Recruited participant tracking              |
| `qqc_web_mrirunsheet`                 | Internal MR run sheet annotations           |
| `qqc_web_mrizip`                      | DICOM zip files (cleaned, most recent)      |
| `qqc_web_qqc`                         | Main QC entity for a given MRI zip          |
| `qqc_web_visualqualitycontrolsummary` | QC score summaries                          |
| `qqc_web_qqcrescan`                   | Rescan records                              |
| `qqc_web_qqcreupload`                 | Reupload tracking                           |
| `qqc_web_investigate`                 | Investigation logs                          |
| `qqc_web_site`                        | Site and network info                       |

---

## 🧩 Key Features

* **Dynamic Timepoint Join**: Automatically includes both `Baseline` and `Followup` timepoints via a `CROSS JOIN`.
* **Comprehensive Status Mapping**: Uses `CASE` statements to derive interpretable status labels for Sankey or dashboard use.
* **Flexible Handling of Investigations**: Uses two levels of investigation joins (`qqc_id`-based and fallback `subject_id`-based).
* **Missing Data Capture**: Combines baseline and follow-up missing data forms via `COALESCE`.
* **Run Sheet Comments & Completion**: Extracts key fields from JSON-formatted REDCap forms for QC tracking.
* **Filters Invalid Rescans**: Ensures only original scans are included by filtering out `self_rescan`.

---

## ✅ Output Columns

| Column                    | Description                                                  |
| ------------------------- | ------------------------------------------------------------ |
| `subject_id`              | Unique subject ID                                            |
| `timepoint`               | Baseline or Followup                                         |
| `sankey_status_tmp`       | High-level status category                                   |
| `sankey_status_tmp_tmp`   | Detailed status with reupload/investigation context          |
| `chrmiss_*`               | Missing data form fields                                     |
| `run_sheet_*`             | Fields from MRI run sheet (e.g., comments, percent complete) |
| `filename`                | Final included MRI zip file                                  |
| `qc_summary_score`        | Numeric QC score                                             |
| `investigate_result`      | Any notes from ongoing investigation                         |
| `reupload_issue_resolved` | Boolean flag for reupload completion                         |

---

## 📌 Filtering Logic

```sql
WHERE 
    subject.recruited = TRUE
    AND self_rescan.qqcrescan_id IS NULL
```

This ensures we only include actively recruited participants and exclude scans that were superseded by rescans.

---

## 🛠 Notes

* All `form_data` fields are extracted from JSON objects using `->>` operators.
* Uses `COALESCE` to seamlessly merge baseline/followup data.
* Designed for dashboards or CSV exports for program coordinators and QC staff.
* Requires materialized view or scheduled refresh for performance in large datasets.

---

## 📊 Example Use Cases

* Powering a **QC Dashboard** using Apache Superset or Django Admin
* Feeding **Sankey diagrams** for MRI data pipeline completion
* Generating reports for **site coordinators** on scan completion and data issues
* Automating identification of **investigation/reupload** needs

