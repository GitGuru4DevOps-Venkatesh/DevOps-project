provider "google" {
  project = "first-fortress-423814-j4"
  region  = "us-central1-f"
}

resource "google_container_cluster" "primary" {
  name     = "primary-cluster"
  location = "us-central1-f"

  node_config {
    machine_type = "n2-standard-2"
  }

  initial_node_count = 2
}

