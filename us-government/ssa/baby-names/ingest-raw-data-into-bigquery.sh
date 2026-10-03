#!/usr/bin/env bash
set -euo pipefail

# Name = ingest-raw-data-into-bigquery.sh
# Location = retrieving-public-data/us-government/ssa/baby-names
# 
# PURPOSE - Move downloaded data from GCS bucket to GCS staging table.
#
# Change History:
# 2026-10-03 Steve Hager 	v1.0	Created to upload first name data (originally from SSA site) to GCP's BigQuery.

gcs_source_URI='gs://shager-raw-us-govt-ssa-babynames/yob*.txt'
target_bq_dataset="raw_us_govt"

# Build external table to read data from GCS.
bq query --use_legacy_sql=false <<EOF

CREATE OR REPLACE EXTERNAL TABLE 
     ${target_bq_dataset}.baby_first_names_ext (
  		first_name STRING,
		sex_code   STRING,
		birth_cnt  INT64
	)
OPTIONS (
  format = 'CSV',
  uris   = ['${gcs_source_URI}']
);
EOF

# Build  a standard table and load it from data data read from GCS.
bq query --use_legacy_sql=false <<EOF
CREATE OR REPLACE TABLE 
     ${target_bq_dataset}.baby_first_names 
AS
SELECT
  CAST(REGEXP_EXTRACT(_FILE_NAME, r'yob(\d{4})\.txt') AS INT64) AS birth_year,
  first_name,
  sex_code,
  birth_cnt
FROM
     ${target_bq_dataset}.baby_first_names_ext 
;

ALTER TABLE 
     ${target_bq_dataset}.baby_first_names
ALTER COLUMN sex_code SET OPTIONS (
  description = 'Sex as recorded on the SSA card application: M = male, F = female'
);
EOF

# Query table and summarize the results.
bq query --use_legacy_sql=false <<EOF
SELECT 
      COUNT(DISTINCT birth_year) AS year_cnt
    , MIN(birth_year)            AS first_year
    , MAX(birth_year)            AS last_year
    , SUM(birth_cnt)             AS total_births
FROM 
     ${target_bq_dataset}.baby_first_names
;
EOF

echo "INFO: $0 complete."
#EOJ cleanup
