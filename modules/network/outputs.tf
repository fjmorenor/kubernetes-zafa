output "vpc_self_link" {
  value = google_compute_network.vpc.self_link
}

output "subnet_standard_id" {
  value = google_compute_subnetwork.subnet_standard.self_link
}

output "subnet_autopilot_id" {
  value = google_compute_subnetwork.subnet_autopilot.self_link
}

output "vpc_name" {
  value = google_compute_network.vpc.name
}