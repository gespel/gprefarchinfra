//resource "random_id" "bucket_prefix" {
//  byte_length = 8
//}

//resource "google_storage_bucket" "default" {
//  name          = "${random_id.bucket_prefix.hex}-bucket-tfstate"
//  force_destroy = false
//  location      = "EU"
//  storage_class = "STANDARD"
//  versioning {
//    enabled = true
//  }
//  encryption {
//    default_kms_key_name = google_kms_crypto_key.terraform_state_bucket.id
//  }
//  depends_on = [
//    google_project_iam_member.default
//  ]
//}

//===========================================================
provider "google" {
  project = "gp-dssi"
  region  = "europe-west3"
}

resource "google_container_cluster" "primary" {
  deletion_protection = false
  name                = "psi-default-cluster"
  location            = "europe-west3-b"

  initial_node_count = 1

  remove_default_node_pool = true
}

resource "google_container_node_pool" "primary_nodes" {
  cluster  = google_container_cluster.primary.name
  location = google_container_cluster.primary.location
  name     = "primary-node-pool"
  node_count = 1

  node_config {
    spot = true
    machine_type = "e2-standard-4"
  }
}

data "google_client_config" "default" {}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "null_resource" "get_credentials" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials psi-gp-cluster --region europe-west3-b"
  }

  depends_on = [
    google_container_node_pool.primary_nodes
  ]
}
