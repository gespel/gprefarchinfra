variable "cluster-name" {
  description = "Name of the cluster"
  type = string
}

variable "gcloud_region" {
  description = "The region the cluster is supposed to be allocated"
  type        = string
}

variable "gcloud_project" {
  description = "The project of the cluster"
  type        = string
}

variable "gcloud_machine_type_main" {
  description = "Type of the main postgres machines"
  type        = string
}
variable "gcloud_node_count" {
  description = "Number of K8s nodes to be created"
  type        = number
}
variable "gcloud_zones" {
  description = "list of zones for the instances"
  type        = list(string)
}
//===========================================================
provider "google" {
  project = var.gcloud_project
  region  = var.gcloud_region
}

resource "google_container_cluster" "primary" {
  deletion_protection = false
  name                = var.cluster-name
  location            = var.gcloud_zones[0]

  initial_node_count = 1

  remove_default_node_pool = true
}

resource "google_container_node_pool" "primary_nodes" {
  cluster  = google_container_cluster.primary.name
  location = google_container_cluster.primary.location
  name     = "primary-node-pool"
  node_count = var.gcloud_node_count

  node_config {
    spot = true
    machine_type = var.gcloud_machine_type_main
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
    command = format("gcloud container clusters get-credentials %s", var.cluster-name)
  }

  depends_on = [
    google_container_node_pool.primary_nodes
  ]
}
