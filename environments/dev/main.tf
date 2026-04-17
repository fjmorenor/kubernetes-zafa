#################################################################################
# 1. MÓDULO DE APIS: El "Interruptor del Proyecto DEV"
#################################################################################
module "apis" {
  source     = "../../modules/apis"
  project_id = var.project_id # Activa APIs en landing-dev-zafa
  mode       = "dev"          # Habilita Container API para poder usar GKE
}

#################################################################################
# 2. SERVICE ACCOUNT (GKE STANDARD): La "Identidad de las Máquinas"
#################################################################################
# Los nodos de un cluster Standard son máquinas virtuales. Necesitan una identidad
# para poder escribir logs o descargar imágenes de disco.
module "sa_gke_nodes" {
  source          = "../../modules/iam"
  project_id      = var.project_id
  sa_id           = var.sa_id
  sa_display_name = "SA para nodos de GKE standard"

  # Roles mínimos recomendados por Google para que el cluster funcione:
  roles = [ 
    "roles/logging.logWriter",      # Para enviar logs a Cloud Logging
    "roles/monitoring.metricWriter", # Para enviar métricas de CPU/RAM
    "roles/monitoring.viewer",       # Para que los nodos vean el estado del monitoreo
    "roles/storage.objectViewer"     # Para descargar imágenes de contenedores desde Artifact Registry
  ]
  depends_on = [ module.apis ]       # No se puede crear una SA si la API de IAM no está activa
}

#################################################################################
# 3. SERVICE ACCOUNT (GKE AUTOPILOT): La "Identidad Gestionada"
#################################################################################
# Autopilot gestiona los nodos por ti, pero sigue necesitando una identidad
# para las tareas de telemetría y logging.
/*module "sa_gke_autopilot" {
  source          = "../../modules/iam"
  project_id      = var.project_id
  sa_id           = "sa-gke-autopilot"
  sa_display_name = "Sa para nodos GKE Autopilot"

  roles = [ 
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/stackdriver.resourceMetadata.writer", # Requerido específicamente por Autopilot para metadatos
   ]

  depends_on = [ module.apis ]
}
*/

#################################################################################
# 4. GKE STANDARD: El "Cluster Manual"
#################################################################################
# Aquí tienes control total sobre los nodos (tamaño de máquinas, cantidad, etc.)
module "gke_standard" {
  source          = "../../modules/gke-standard"
  project_id      = var.project_id
  region          = var.region
  cluster_name    = "gke-standard-kubernetes"
  host_project_id = var.host_project_id # CONEXIÓN: Sabe que la red vive en el proyecto HOST

  # CONEXIÓN DE RED: Usa las URLs (self_links) que apuntan a la VPC del HOST
  vpc_self_link    = var.vpc_self_link
  subnet_self_link = var.subnet_standard_self_link

  # RANGOS SECUNDARIOS: Deben llamarse igual que los que creamos en el módulo network del HOST
  pods_range_name    = "pods-standard"
  service_range_name = "service-standard"

  # CONEXIÓN IAM: Usa el email generado en el paso #2
  node_sa_email = module.sa_gke_nodes.email

  # CONFIGURACIÓN FÍSICA
  machine_type = "e2-medium"
  min_nodes    = 1
  max_nodes    = 2

  # SOLUCIÓN STOCKOUT: Forzamos a evitar la zona 'd' que estaba llena
  node_locations = ["europe-west1-b", "europe-west1-c"]

  depends_on = [ module.sa_gke_nodes ] # No se crea el cluster sin su identidad
}

#################################################################################
# 5. GKE AUTOPILOT: El "Cluster Manos Libres"
#################################################################################
# Google gestiona la infraestructura. Tú solo despliegas apps y pagas por uso.
/*module "gke_autopilot" {
  source          = "../../modules/gke-autopilot"
  project_id      = var.project_id
  region          = var.region
  cluster_name    = "gke-autopilot-kubernetes"

  # CONEXIÓN DE RED: Usa su propia subred dedicada dentro de la VPC del HOST
  vpc_self_link    = var.vpc_self_link
  subnet_self_link = var.subnet_autopilot_self_link

  pods_range_name    = "pods-autopilot"
  service_range_name = "services-autopilot"

  # CONEXIÓN IAM: Usa su propia SA creada en el paso #3
  node_sa_email = module.sa_gke_autopilot.email
  
  depends_on = [ module.sa_gke_autopilot ]
}
*/

module "cloud-sql" {
  source = "../../modules/clud-sql"
  instance_name = var.instance_name
  region = var.region
  db_name = var.db_name
  user_name = var.user_name
  user_password = var.user_password
  }

