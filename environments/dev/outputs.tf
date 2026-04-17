# ARCHIVO: environments/dev/outputs.tf
output "gke_standard_endpoint" {
  value = module.gke_standard.cluster_endpoint
}
/*
output "gke_autopilot_endpoint" {
  value = module.gke_autopilot.cluster_endpoint
}
*/

output "db_connection_string" {
  value = module.cloud-sql.db_connection_string
  
}