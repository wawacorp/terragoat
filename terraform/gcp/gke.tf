data "google_compute_zones" "available_zones" {
  project = var.project
  region  = var.region
}

resource "google_container_cluster" "workload_cluster" {
  name               = "terragoat-${var.environment}-cluster"
  logging_service    = "none"
  location           = var.region
  initial_node_count = 1

  monitoring_service       = "none"
  remove_default_node_pool = true
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.public-subnetwork.name
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "0.0.0.0/0"
    }
  }
  pod_security_policy_config {
    enabled = true
  }
  network_policy {
  }
  min_master_version = "1.12"
  enable_intranode_visibility = true
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "custom_node_pool" {
  cluster  = google_container_cluster.workload_cluster.name
  location = var.region

  node_config {
    shielded_instance_config {
      enable_secure_boot = true
    }
    image_type = "Ubuntu"
  }
  management {
    auto_repair = true
    auto_upgrade = true
  }
}
