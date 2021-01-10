provider "google-beta" {
  credentials = file(var.credentials_file)
  project = var.project
  region  = "us-central1"
  zone    = "us-central1-f"
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = "us-central1-f"
  provider = google-beta

      # Roman Mamchur - below recommendation from terraform - 
      #    but I'm not deleting the node pool for development speed
      # Terraform recomended:
      # We can't create a cluster with no node pool defined, but we want to only use
      # separately managed node pools. So we create the smallest possible default
      # node pool and immediately delete it.
#      remove_default_node_pool = true
      initial_node_count = 1

      vertical_pod_autoscaling { 
         enabled = true 
      }

      master_auth {
        username = var.cluster_user_name
        password = var.cluster_user_password

        client_certificate_config {
          issue_client_certificate = false
        }
      }
  node_config {
    preemptible  = var.preemptible
  }
}

resource "google_container_node_pool" "web_nodes" {
  name       = "node-pool-web"
  location   = "us-central1-f"
  cluster    = google_container_cluster.primary.name
  provider = google-beta

  node_count = 2
#  initial_node_count = 1
#  autoscaling { 
#             min_node_count = 1 
#             max_node_count = 3
#  }

  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type_web
    disk_size_gb = 10

    metadata = {
       disable-legacy-endpoints = "true"
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/projecthosting",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/source.read_write",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
    labels = {
      node = "web"
    }

    tags = ["node", "web"]
  }
}

resource "google_compute_firewall" "allow-healthcheck" {
  name    = "endpoint"
  network =  "default"
  provider = google-beta

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }
}

