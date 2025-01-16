terraform {
    backend "gcs" {
        bucket  = "bucket-tfstate-gp-dssi"
        prefix  = "terraform/state"
    }
}