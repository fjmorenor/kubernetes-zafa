# PASO 1: Crear el carnet de identidad (Service Account)
resource "google_service_account" "static_sa" {
    project = var.project_id
    account_id = var.sa_id
    display_name = var.sa_display_name
}

# PASO 2: Darle sus llaves (Roles)
# Usamos un for_each sencillo sobre la lista de roles
resource "google_project_iam_member" "asignar_roles" {
    for_each = toset(var.roles)
    project = var.project_id
    role = each.value
    member = "serviceAccount:${google_service_account.static_sa.email}"
    
}

