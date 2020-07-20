# Provide 
provider "google"{
    credentials = "${file("token.json")}"
    project = "${var.project_name}"
    region = "${var.region}"
    zone = "${var.zone}"
}

# Configure the backend
terraform {
  backend "gcs" {
    bucket      = "tf_backend_gcp_banuka_jana_jayarathna"
    prefix      = "terraform/state"
    credentials = "token.json"
  }
}
