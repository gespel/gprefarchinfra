provider "google" {
  project = "gp-dssi"
  region  = "europe-west10"
  //zone    = var.gcloud_region
}

resource "google_compute_instance" "gitlab" {
  count        = 1
  name         = "gitlab"
  machine_type = "e2-standard-2"
  zone         = "europe-west10-a"

  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  boot_disk {
    initialize_params {
      image = "opensuse-leap-15-6-v20241004-x86-64"
    }
  }

  network_interface {
    network = "default"
    # Kein access_config -> keine öffentliche IP
  }

  service_account {
    email  = "image-puller@gp-dssi.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    mount -o remount,rw /
    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install
    sudo snap install docker
  EOT

  tags = ["gitlab"]
}