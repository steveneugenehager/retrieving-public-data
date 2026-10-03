#!/usr/bin/env bash
set -euo pipefail

# Name =  retrieve-baby-names-by-year.sh
# Location = retrieving-public-data/us-government/ssa/baby-names
# 
# PURPOSE - download first name data from US government website. May be used in generating synthetic data.

# Dataset metadata at --> https://catalog.data.gov/dataset/baby-names-from-social-security-card-applications-national-data

# The data (name, year of birth, sex, and count) are from a 100 percent sample of Social Security card applications for 1880 on.
# (except that names with count < 5 are not included.)

# Change History:
# 2026-10-03 Steve Hager 	v1.0	Created to download first name data from SSA site. Data expected to be staged in cloud storage.

# wget isn't guaranteed to be installed, so this check will end the script immediately if missing.
# I considered alternatives, but installing it here would mean maintaining a sudoer's file/entry for the install command.
if ! command -v wget >/dev/null 2>&1; then
    echo "wget is not installed. Install it with: sudo apt install wget" >&2
    exit 1
fi

# Set up variables for the source data.
remote_host="www.ssa.gov"
remote_dir="oact/babynames"
remote_file="names.zip"
remote_URL="https://${remote_host}/${remote_dir}/${remote_file}"
echo "INFO: Downloading ${remote_URL}"

# Set up variables for the data download location.
local_download_target_dir="downloads"
local_data_target_subdir="baby-names-from-social-security-card-applications"
local_download_dir="$HOME/${local_download_target_dir}/${local_data_target_subdir}"
local_data_dir="$HOME/${local_download_target_dir}/${local_data_target_subdir}/data"
echo "INFO: Files to be downloaded to: ${local_download_dir}"

# ensure a temporary folder is created to stage the data on the VM before upload to cloud storage.
# The -p flag makes mkdir succeed quietly if the directory already exists, and it also creates any missing parent directories along the way:
mkdir -p "${local_download_dir}"

# Ensure directory is empty.
find "${local_download_dir:?}" -mindepth 1 -delete

# curl wasn't allowed by SSA, so wget was used, but it might not be installed on the Linux VM.
cd "${local_download_dir}"
wget "${remote_URL}"

#Extract data files from zipfile into a raw data folder
echo "INFO: Data files to be extracted to: ${local_data_dir}"
mkdir -p "${local_data_dir}"
cd "${local_data_dir}"

# Make unzip output uncluttered and a clear error message if if fails.
if ! unzip "${local_download_dir}/${remote_file}" >/dev/null 2>&1; then
    echo "ERROR: ${remote_file} is not a valid ZIP (download may have been blocked)." >&2
    exit 1
fi

# Display the downloaded data files. 
echo "INFO: Data files staged in: ${local_data_dir}"
cd "${local_data_dir}"
ls *.txt

# Summarize the downloaded data files. 
shopt -s nullglob
files=(${local_data_dir}/yob*.txt)
echo "INFO: Count of text/data files is: ${#files[@]}"

# Reasonability check on the number of files retrieved.
if (( ${#files[@]} < 146 )); then
    echo "ERROR: Expected about 146 year files; found ${#files[@]}." >&2
    exit 1
fi

#EOJ cleanup
rm "${local_download_dir}/${remote_file}"
rm -f "${local_data_dir:?}"/*.pdf
echo "INFO: $0 complete."
