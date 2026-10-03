# create-baby-names-bucket-in-GCS.tf


# Change History:
# 2026-10-03 Steve Hager    v1.0  Created.

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
  location                    = "US-CENTRAL1"
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
