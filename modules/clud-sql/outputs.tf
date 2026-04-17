output "db_connection_string" {
  value = google_sql_database_instance.instance.connection_name
}

output "public_ip" {
  value = google_sql_database_instance.instance.public_ip_address
  }