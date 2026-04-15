resource "google_compute_router" "router" {
    project = var.project_id
    name = "router-kubernetes"
    region = var.region
    network = var.vpc_name
    
}

resource "google_compute_router_nat" "nat" {
    project = var.project_id
    name = "nat-kubernetes"
    router = google_compute_router.router.name
    region = var.region
    nat_ip_allocate_option = "AUTO_ONLY"

    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
    
}