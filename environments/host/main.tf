#################################################################################
# 1. MÓDULO DE APIS: El "Interruptor"
#################################################################################
module "apis" {
  source     = "../../modules/apis"
  project_id = var.project_id   # Activa las APIs en el proyecto landing-host-zafa
  mode       = "host"           # Indica al módulo que habilite servicios de red (Compute, Container, etc.)
}

#################################################################################
# 2. MÓDULO DE RED: El "Cimiento"
#################################################################################
module "network" {
  source     = "../../modules/network"
  project_id = var.project_id   # Crea la red en el proyecto HOST
  region     = var.region       # Define dónde se ubicarán físicamente las subredes
  vpc_name   = var.vpc_name # Nombre de la red troncal

  # Este módulo crea las subredes internas (Standard y Autopilot) y sus rangos secundarios (Pods/Services)
  depends_on = [module.apis]    # No puede crear red si las APIs de Compute no están activas
}

#################################################################################
# 3. MÓDULO DE FIREWALL: La "Seguridad"
#################################################################################
module "firewall" {
  source     = "../../modules/firewall"
  project_id = var.project_id
  vpc_name   = module.network.vpc_name # CONEXIÓN: Usa el nombre de la red que acaba de crear el módulo anterior
  depends_on = [ module.network ]      # No puede haber reglas si no existe la red (VPC)
}

#################################################################################
# 4. MÓDULO CLOUD NAT: La "Salida a Internet"
#################################################################################
module "cloud_nat" {
  source     = "../../modules/cloud-nat"
  project_id = var.project_id
  region     = var.region
  vpc_name   = module.network.vpc_name # CONEXIÓN: Conecta el router de salida a la VPC creada
  depends_on = [ module.network ]      # Espera a que la red esté lista
}

#################################################################################
# 5. MÓDULO SHARED VPC: El "Puente"
#################################################################################
module "shared_vpc" {
  source             = "../../modules/shared-vpc"
  host_project_id    = var.project_id     # landing-host-zafa se convierte en el HOST oficial
  service_project_id = var.dev_project_id  # landing-dev-zafa se vincula como "proyecto de servicio"
  depends_on         = [ module.network ]  # La red debe estar lista para ser compartida
}



#################################################################################
# 6. PERMISOS IAM: "Dándole las llaves al proyecto DEV"
# El proyecto DEV tiene un "Robot de GKE" que necesita entrar en el proyecto HOST.
#################################################################################

# Permiso para usar la subred de Autopilot
resource "google_compute_subnetwork_iam_member" "gke_service_agent_network_user_autopilot" {
  project    = "landing-host-zafa"
  region     = "europe-west1"
  subnetwork = "subnet-gke-autopilot"      # CONEXIÓN: Apunta a la subred creada en el módulo network
  role       = "roles/compute.networkUser" # Permite que el cluster de DEV "se enchufe" aquí
  member     = "serviceAccount:service-932038588586@container-engine-robot.iam.gserviceaccount.com" # Robot de GKE del proyecto DEV
}

# Permiso para usar la subred de Standard
resource "google_compute_subnetwork_iam_member" "gke_service_agent_network_user_standard" {
  project    = "landing-host-zafa"
  region     = "europe-west1"
  subnetwork = "subnet-gke-standard"
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:service-932038588586@container-engine-robot.iam.gserviceaccount.com"
}

# Permiso general a nivel de proyecto HOST para que el robot de GKE de DEV pueda ver recursos de red
resource "google_project_iam_member" "gke_host_agent_fix" {
  project = "landing-host-zafa"
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:service-932038588586@container-engine-robot.iam.gserviceaccount.com"
}

# Permiso para la cuenta de servicios de Google (infraestructura básica) de DEV sobre el HOST
resource "google_project_iam_member" "google_apis_network_user" {
  project = "landing-host-zafa"
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:932038588586@cloudservices.gserviceaccount.com"
}

# Refuerzo: El robot de GKE de DEV debe ser Usuario de Red en el HOST
resource "google_project_iam_member" "gke_robot_network_user" {
  project = "landing-host-zafa"
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:service-932038588586@container-engine-robot.iam.gserviceaccount.com"
}

# Permiso de "Mirada" (Security Reviewer): Permite al robot de DEV leer la seguridad del HOST
# Esto es necesario para que el cluster verifique que las subredes son compatibles.
resource "google_project_iam_member" "gke_host_viewer" {
  project = "landing-host-zafa"
  role    = "roles/iam.securityReviewer" 
  member  = "serviceAccount:service-932038588586@container-engine-robot.iam.gserviceaccount.com"
}

# Permiso de Agente de Servicio: Es el rol más potente para que el robot de GKE de DEV
# pueda gestionar balanceadores de carga y firewall en el proyecto HOST.
resource "google_project_iam_member" "gke_service_agent_role" {
  project = "landing-host-zafa"
  role    = "roles/container.serviceAgent"
  member  = "serviceAccount:service-932038588586@container-engine-robot.iam.gserviceaccount.com"
}