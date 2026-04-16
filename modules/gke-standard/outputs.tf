# ARCHIVO: modules/gke-standard/outputs.tf
output "cluster_endpoint" {
  description = "El endpoint del cluster GKE"
  # Asegúrate que aquí usas el nombre que le diste al recurso cluster (standard o primary)
  value       = google_container_cluster.standard.endpoint 
}
/*
output "cluster_endpoint" {
  value = google_container_cluster.standard.endpoint
}
*/