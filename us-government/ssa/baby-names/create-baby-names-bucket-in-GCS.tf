# create-baby-names-bucket-in-GCS.tf


# Change History:
# 2026-10-03 Steve Hager    v1.0  Created.
# 2026-10-03 Steve Hager    v1.1  Added BigQuery dataset. Added var.location to ensure bucket and BQ dataset are in same region.

variable "location" {
  type    = string
  default = "us-central1"
}

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = "demonstration-shager"
  region  = "us-central1"
}

resource "google_storage_bucket" "raw-us-govt-ssa-babynames" {

  name                        = "shager-raw-us-govt-ssa-babynames"
  location                    = var.location
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle_rule {
    condition {
      age = 7
    }
    action {
      type = "Delete"
    }
  }
}

resource "google_bigquery_dataset" "bq_ds_raw_us_govt" {
  dataset_id  = "raw_us_govt"
  location    = var.location
  description = "Raw US Government Public Data."

  # Safety catch: destroy fails if the dataset still holds tables.
  delete_contents_on_destroy = false
}
