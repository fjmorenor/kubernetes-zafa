output "firewall_rules" {
  value = [
    google_compute_firewall.allow_internal.name,
    google_compute_firewall.allow_health_check,
    google_compute_firewall.allow_master_to_nodes.name
  ]
}