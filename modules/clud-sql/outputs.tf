output "db_connection_string" {
  value = module.mi_base_de_datos.intance_connection_name
}

output "public_ip" {
  value = google_sql_database_instance.instance.public_ip_address
  }