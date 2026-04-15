resource "google_compute_shared_vpc_host_project" "host" {
    project = var.host_project_id
    
}

resource "google_compute_shared_vpc_service_project" "dev" {
    host_project = var.host_project_id
    service_project = var.service_project_id
    
    depends_on = [google_compute_shared_vpc_host_project.host]
}