provider "google" {
  project = "gp-dssi"
  region  = "europe-west10"
  //zone    = var.gcloud_region
}

resource "google_compute_disk" "ds-disk" {
    name         = "ds-disk"
    image        = "opensuse-leap-15-6-v20241004-x86-64"
    zone         = "europe-west10-a"
    type         = "pd-balanced"
    size         = 150
}

resource "google_compute_instance" "distribution_server" {
  count        = 1
  name         = "distribution-server"
  machine_type = "e2-standard-2"
  zone         = "europe-west10-a"

  scheduling {
    preemptible       = true
    automatic_restart = false # Bei preemptible muss dies auf false gesetzt sein
  }

  boot_disk {
    source = google_compute_disk.ds-disk.self_link
  }

  network_interface {
    network = "default"
  }
  service_account {
    email  = "image-puller@gp-dssi.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    # Aktivieren des Schreibmodus für das Root-Dateisystem
    mount -o remount,rw /
    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install
    sudo snap install docker
  EOT

  tags = ["ds"]
}