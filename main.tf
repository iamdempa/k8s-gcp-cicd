# Provide 
provider "google" {
  credentials = "${file("token.json")}"
  project     = "${var.project_name}"
  region      = "${var.region}"
  zone        = "${var.zone}"
}

# Configure the backend
terraform {
  backend "gcs" {
    bucket      = "tf_backend_gcp_banuka_jana_jayarathna"
    prefix      = "terraform/state"
    credentials = "token.json"
  }
}

# create vpc
resource "google_compute_network" "kubernetes-vpc" {
  name = "kubernetes-vpc"
  auto_create_subnetworks = "false"
}

# create subnect for kube-master
resource "google_compute_subnetwork" "kube-master-subnet" {
  name          = "kube-master-subnet"
  ip_cidr_range = "10.0.0.0/21"
  region        = "us-central1"
  network       = google_compute_network.kubernetes-vpc.id
  depends_on = ["google_compute_network.kubernetes-vpc"]
}

# create subnet for kube-minions
resource "google_compute_subnetwork" "kube-minion-subnet" {
  name          = "kube-minion-subnet"
  ip_cidr_range = "10.0.8.0/21"
  region        = "us-central1"
  network       = google_compute_network.kubernetes-vpc.id
  depends_on = ["google_compute_network.kubernetes-vpc"]
}

resource "google_compute_instance" "default" {
  name         = "banuka-test"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "echo hi > /test.txt"
}
