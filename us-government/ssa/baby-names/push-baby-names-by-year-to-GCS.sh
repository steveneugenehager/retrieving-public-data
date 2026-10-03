#!/usr/bin/env bash
set -euo pipefail

# Name = push-baby-names-by-year-to-GCS.sh
# Location = retrieving-public-data/us-government/ssa/baby-names
# 
# PURPOSE - Move downloaded data from VM to GCS bucket.
#
# Change History:
# 2026-10-03 Steve Hager 	v1.0	Created to upload first name data (originally from SSA site) to Google cloud storage.

# Check that gcloud is installed. Clear error message if not.
if ! command -v gcloud >/dev/null 2>&1; then
    echo "ERROR: gcloud is not installed. See https://cloud.google.com/sdk/docs/install" >&2
    exit 1
fi

# Verify GCP auth active and display which one is being used.
active_account=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null || true)
if [[ -z "${active_account}" ]]; then
    echo "ERROR: gcloud has no active account. Run: gcloud auth login" >&2
    exit 1
fi
echo "INFO: Using gcloud account: ${active_account}"

# Set up variables for placement in GCS.
gcs_target_bucket="shager-raw-us-govt-ssa-babynames"

# Set up variables for the source data (local on the VM).
local_download_target_dir="downloads"
local_data_target_subdir="baby-names-from-social-security-card-applications"
local_download_dir="$HOME/${local_download_target_dir}/${local_data_target_subdir}"
local_data_dir="$HOME/${local_download_target_dir}/${local_data_target_subdir}/data"
echo "INFO: Files to be uploaded to GCS found in: ${local_data_dir}"

# Sanity check that files exist to be uploaded.
shopt -s nullglob
local_files=("${local_data_dir}"/yob*.txt)
if (( ${#local_files[@]} == 0 )); then
    echo "ERROR: No yob*.txt files found in ${local_data_dir}. Run the download script first." >&2
    exit 1
fi

# Upload the local files to GCS.
gcloud storage cp "${local_data_dir}/yob*.txt" "gs://${gcs_target_bucket}/"

# Display the last 10 staged data files in GCS. 
echo "INFO: Display the last 10 files staged in: gs://${gcs_target_bucket}/"
gcloud storage ls "gs://${gcs_target_bucket}/" | tail -n 10

# summarize the staged data files in GCS. 
remote_file_count=$(gcloud storage ls "gs://${gcs_target_bucket}/yob*.txt" | wc -l)
echo "INFO: Count of text/data files in GCS is: ${remote_file_count}"

#EOJ cleanup
echo "INFO: $0 complete."
