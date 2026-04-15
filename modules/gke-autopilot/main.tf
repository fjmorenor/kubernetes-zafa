resource "google_container_cluster" "autopilot" {
    project = var.project_id
    name = var.cluster_name
    provider = google-beta
    location = var.region

    enable_autopilot = true

    network = var.vpc_self_link
    subnetwork = var.subnet_self_link

    ip_allocation_policy {
      cluster_secondary_range_name = var.pods_range_name
      services_secondary_range_name = var.service_range_name
    }

    private_cluster_config {
      enable_private_nodes = true
      enable_private_endpoint = false
      master_ipv4_cidr_block = "172.16.1.0/28"
}

release_channel {
  channel = "REGULAR"
}

deletion_protection = false

}