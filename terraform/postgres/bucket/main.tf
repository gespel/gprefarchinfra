variable "gcloud_region" {
  description = "The region the cluster is supposed to be allocated"
  type        = string
}

variable "gcloud_project" {
  description = "The project of the cluster"
  type        = string
}

provider "google" {
  project = "${var.gcloud_project}"
  region  = "${var.gcloud_region}"
  zone    = "${var.gcloud_region}-a"
}

resource "google_storage_bucket" "default_bucket" {
  name          = "bucket-tfstate-gp-dssi"
  force_destroy = true
  location      = "europe-west10"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
  #encryption {
    #default_kms_key_name = google_kms_crypto_key.terraform_state_bucket.id
  #}
  #depends_on = [
  #  google_project_iam_member.default
  #]
}