resource "google_sql_database_instance" "instance" {
    name = var.instance_name
    region = var.region
    database_version = "POSTGRES_15"
    settings {
      tier = "db-f1-micro"
    }
    deletion_protection = false
    
}

resource "google_sql_database" "datase" {
    name = var.db_name
    instance = google_sql_database_instance.instance.name
    
}

resource "google_sql_user" "users" {
    name = var.user_name
    instance = google_sql_database_instance.instance.name
    password = var.user_password
    
}