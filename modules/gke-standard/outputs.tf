output "cluster_name" {
  value = google_container_cluster.standard.endpoint
}
/*
output "cluster_endpoint" {
  value = google_container_cluster.standard.endpoint
}
*/