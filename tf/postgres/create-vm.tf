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

variable "gcloud_machine_type_etcd" {
  description = "Type of the etcd quorum machine"
  type        = string 
}

provider "google" {
  project = var.gcloud_project
  region  = var.gcloud_region
  zone    = "${var.gcloud_region}-a"
}

resource "google_compute_firewall" "allow-internal-and-ssh" {
  name    = "allow-internal-and-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22", "5432", "8008", "2379", "2380"] 
  }
  source_ranges = ["0.0.0.0/0"] 
  target_tags   = [var.cluster-name]
}

resource "google_compute_instance" "etcd" {
  count        = 1
  name         = "etcd-3"
  machine_type = var.gcloud_machine_type_etcd

  scheduling {
    preemptible       = true
    automatic_restart = false # Bei preemptible muss dies auf false gesetzt sein
  }

  boot_disk {
    initialize_params {
      image = "opensuse-leap-15-6-v20241004-x86-64"
    }
  }

  network_interface {
    network = "default"

    access_config {
    }
  }
  service_account {
    email  = "image-puller@gp-dssi.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  tags = [var.cluster-name]


  metadata_startup_script = <<-EOT
    #!/bin/bash
    # Aktivieren des Schreibmodus für das Root-Dateisystem
    mount -o remount,rw /

    sudo snap install docker
  EOT
}

resource "google_compute_instance" "patroni_node" {
  count        = 2
  name         = "postgres-${count.index + 1}"
  machine_type = var.gcloud_machine_type_main

  scheduling {
    preemptible       = true
    automatic_restart = false # Bei preemptible muss dies auf false gesetzt sein
  }

  boot_disk {
    initialize_params {
      image = "opensuse-leap-15-6-v20241004-x86-64"
    }
  }

  network_interface {
    network = "default"

    access_config {
    }
  }
  service_account {
    email  = "image-puller@gp-dssi.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  tags = ["${var.cluster-name}"]

  metadata_startup_script = <<-EOT
    #!/bin/bash
    # Aktivieren des Schreibmodus für das Root-Dateisystem
    mount -o remount,rw /

    sudo snap install docker
  EOT
}
#docker run -d --name patroni -p 5432:5432 -p 8008:8008 -e PATRONI_NAME=patroni-1 -e PATRONI_SCOPE=postgres_cluster -e PATRONI_RESTAPI_LISTEN=0.0.0.0:8008 -e PATRONI_RESTAPI_CONNECT_ADDRESS=34.32.82.98:8008       -e PATRONI_POSTGRESQL_LISTEN=0.0.0.0:5432       -e PATRONI_POSTGRESQL_CONNECT_ADDRESS=34.32.82.98:5432       -e PATRONI_ETCD_HOSTS=10.128.0.2:2379,10.128.0.3:2379,10.128.0.4:2379 infisical/patroni:latest
