#!/usr/bin/env bash
set -euo pipefail

# Name = push-baby-names-by-year-to-GCS.sh
# Location = retrieving-public-data/us-government/ssa/baby-names
# 
# PURPOSE - Move downloaded data from VM to GCS bucket.
#
# Change History:
# 2026-10-03 Steve Hager 	v1.0	Created to download first name data from SSA site. Data expected to be staged in cloud storage.

# Set up variables for placement in GCS.
gcs_target_bucket="shager-raw-us-govt-ssa-babynames"

# Set up variables for the source data (local on the VM).
local_download_target_dir="downloads"
local_data_target_subdir="baby-names-from-social-security-card-applications"
local_download_dir="$HOME/${local_download_target_dir}/${local_data_target_subdir}"
local_data_dir="$HOME/${local_download_target_dir}/${local_data_target_subdir}/data"
echo "INFO: Files to be uploaded to GCS found in: ${local_download_dir}"

# Upload the local files to GCS.
gcloud storage cp "${local_data_dir}/yob*.txt" gs://${gcs_target_bucket}/

# Display the staged data files in GCS. 
echo "INFO: Data files staged in: gs://${gcs_target_bucket}/"
gcloud storage ls gs://${gcs_target_bucket}/

# summarize the staged data files in GCS. 
remote_file_count=$(gcloud storage ls gs://${gcs_target_bucket}/ | wc -l)
echo "INFO: Count of text/data files in GCS is: ${remote_file_count}"

#EOJ cleanup
echo "INFO: $0 complete."
