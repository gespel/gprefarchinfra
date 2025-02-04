provider "google" {
  project = "gp-dssi"
  region  = "europe-west10"
  //zone    = var.gcloud_region
}

resource "google_compute_instance" "oop-wrtier-vm" {
  count        = 1
  name         = "oop-writer-vm"
  machine_type = "e2-standard-2"
  zone         = "europe-west10-a"

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
  #service_account {
  #  email  = "sheimbrodt@psi.de"
  #  scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  #}
  tags = ["oop-writer-vm"]
}