

# -------------------------------------------------------------------------------------------------
# LÓGICA INTERNA (El cerebro que decide qué APIs activar)
# -------------------------------------------------------------------------------------------------

locals {
  # 1. APIs comunes que se activan siempre (Administración, Logs, Almacenamiento)
  apis_common = [
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "storage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]

  # 2. APIs específicas para el proyecto de Red (HOST)
  apis_host = [
    "container.googleapis.com",         # Necesaria para Shared VPC
    "servicenetworking.googleapis.com", # Para conectar servicios internos (peering)
    "dns.googleapis.com",               # Gestión de nombres internos
    "networkmanagement.googleapis.com", # Pruebas de conectividad
  ]

  # 3. APIs específicas para el proyecto de Kubernetes (DEV)
  apis_dev = [
    "container.googleapis.com",         # El motor de GKE
    "artifactregistry.googleapis.com",  # Para guardar tus imágenes de Docker
    "autoscaling.googleapis.com",       # Para que el cluster crezca solo
    "secretmanager.googleapis.com",     # Para guardar contraseñas seguras
    "cloudtrace.googleapis.com", 
    "sqladmin.googleapis.com"       # Para ver el rendimiento de tus apps
  ]

  # 4. CONSTRUCCIÓN DE LA LISTA FINAL:
  # Junta las comunes + (las de host O las de dev) + las extras que tú pidas.
  # 'distinct' elimina los nombres repetidos para evitar conflictos.
  apis_to_enable = distinct(concat(
    local.apis_common,
    var.mode == "host" ? local.apis_host : local.apis_dev,
    var.extra_apis,
  ))
}

# -------------------------------------------------------------------------------------------------
# RECURSO DE GOOGLE (La acción de activar las APIs en la nube)
# -------------------------------------------------------------------------------------------------

resource "google_project_service" "apis" {
  # 'for_each': Lee la lista final y crea un recurso por cada nombre de la lista.
  for_each = toset(local.apis_to_enable)

  project = var.project_id
  
  # 'each.value': Es el nombre de la API que toca activar en esta vuelta del bucle.
  service = each.value

  # SEGURIDAD: Si borras este código, la API se queda encendida en Google Cloud.
  # Esto evita que se borren servicios o datos por accidente.
  disable_on_destroy = false
}