# Provide 
provider "google" {
  credentials = file("token.json")
  project     = var.project_name
  region      = var.region
  zone        = var.zone
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
  name                    = "kubernetes-vpc"
  auto_create_subnetworks = "false"
}

# adding a firewall to the VPC
resource "google_compute_firewall" "kube-master-firewall" {
  name    = "kube-master-firewall"
  network = google_compute_network.kubernetes-vpc.name

  # ssh access 
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # source_tags = ["kube-master-firewall", "0.0.0.0/0"]
  source_ranges = ["0.0.0.0/0"]
}


# adding a route to the VPC to the internet gateway
resource "google_compute_route" "internet-gateway" {
  name        = "internate-gateway"
  dest_range  = "0.0.0.0/0"
  network     = google_compute_network.kubernetes-vpc.name
  next_hop_gateway = "global/gateways/default-internet-gateway"
  priority    = 10
}

# create subnect for kube-master
resource "google_compute_subnetwork" "master-sub" {
  name          = "master"
  ip_cidr_range = "10.0.0.0/21"
  region        = "us-central1"
  network       = google_compute_network.kubernetes-vpc.name
  depends_on    = [google_compute_network.kubernetes-vpc]
  private_ip_google_access = "false"
}

# create subnet for kube-minions
resource "google_compute_subnetwork" "minions-sub" {
  name          = "minion"
  ip_cidr_range = "10.0.8.0/21"
  region        = "us-central1"
  network       = google_compute_network.kubernetes-vpc.name
  depends_on    = [google_compute_network.kubernetes-vpc]
  private_ip_google_access = "true"
}

resource "google_compute_instance" "kube-master" {
  name         = "kube-master"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  tags = ["kube-master"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.master-sub.name

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    Name = "test"
  }

  metadata_startup_script = <<-EOF
              #!/bin/bash    
              sudo apt-get update
              sudo apt-get upgrade -y
              sudo apt install ansible -y       
              echo "${file("${var.public_key_path}")}" >> /root/.ssh/authorized_keys                          
            EOF
  # metadata_startup_script = "echo hi > /test.txt"
}

resource "google_compute_instance" "kube-minion" {
  
  count   = var.minions_count
  name         = "kube-minion-${count.index}"
  machine_type = "n1-standard-1"
  zone         = "us-central1-b"

  tags = ["kube-minion-${count.index}"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.minions-sub.name

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    Name = "minion-${count.index}"
  }

  metadata_startup_script = <<-EOF
              #!/bin/bash    
              sudo apt-get update
              sudo apt-get upgrade -y
              sudo apt install ansible -y       
              echo "${file("${var.public_key_path}")}" >> /root/.ssh/authorized_keys                          
            EOF

  # metadata_startup_script = "echo hi > /test.txt"
}

resource "null_resource" "web3" {

 triggers  = {
    key = "${uuid()}"
  }

  provisioner "local-exec" {
      command = "rm -rf ~/.ssh/known_hosts"
  }

  provisioner "local-exec" {
        command = <<EOD
cat <<EOF > /etc/ansible/hosts
[all] 
${google_compute_instance.kube-master.network_interface.0.access_config.*.nat_ip}
${google_compute_instance.kube-minion[*].network_interface.0.access_config.0.nat_ip}
[kube-master]
${google_compute_instance.kube-master.network_interface.0.access_config.*.nat_ip}
[kube-minions]
${google_compute_instance.kube-minion[*].network_interface.0.access_config.0.nat_ip}
EOF
EOD
  }

 }



output "master-ip" {
    value = ["${google_compute_instance.kube-master.network_interface.0.access_config.*.nat_ip}"]
} 


output "minion-ips" {
    value = ["${google_compute_instance.kube-minion[*].network_interface.0.access_config.0.nat_ip}"]
} 

