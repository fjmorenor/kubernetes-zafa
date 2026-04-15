# ----------------------------------------------------------------------------------
# ARCHIVO: modules/gke-standard/main.tf
# OBJETIVO: Crear el cluster de Kubernetes Standard y su grupo de servidores (nodos).
# ----------------------------------------------------------------------------------

# 1. DEFINICIÓN DEL CLUSTER (El "Cerebro" de Kubernetes)
resource "google_container_cluster" "standard" {
  project  = var.project_id       # ID del proyecto donde se crea el cluster.
  name     = var.cluster_name     # Nombre que le pusiste al cluster.
  provider = google-beta          # Usa funciones avanzadas del proveedor "beta".

  # Regional: el cluster se reparte en varias zonas para que nunca se caiga.
  location = var.region 

  node_locations = var.node_locations

  # Conexión a la red compartida (Shared VPC)
  network    = var.vpc_self_link     # URL de la red VPC del proyecto HOST.
  subnetwork = var.subnet_self_link  # URL de la subred específica del proyecto HOST.

  # Configuración de IPs para los contenedores (Pods)
  networking_mode = "VPC_NATIVE"  # Los pods tienen IPs propias dentro de la red.
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name     # Rango de IPs para los Pods.
    services_secondary_range_name = var.service_range_name # Rango de IPs para los Servicios.
  }

  # Seguridad: Cluster privado (los nodos no se ven desde internet)
  private_cluster_config {
    enable_private_nodes    = true   # Los nodos solo tienen IP privada.
    enable_private_endpoint = false  # El punto de control (API) sí es accesible para ti.
    master_ipv4_cidr_block  = "172.16.0.0/28" # Red interna para que Google gestione el cluster.
  }

  # Canal de actualizaciones estable (recomendado para producción)
  release_channel {
    channel = "REGULAR" 
  }

  # Protección contra borrado accidental (en falso para poder destruirlo en el lab)
  deletion_protection = false 

  # Eliminar el grupo de nodos por defecto (es mejor crear uno propio controlado)
  remove_default_node_pool = true 
  initial_node_count       = 1 
}

# 2. DEFINICIÓN DEL NODE POOL (Los "Músculos" - los servidores reales)
resource "google_container_node_pool" "nodes" {
  project  = var.project_id           # ID del proyecto.
  name     = "${var.cluster_name}-pool" # Nombre del grupo de nodos.
  location = var.region               # Misma región que el cluster.
  cluster  = google_container_cluster.standard.name # Conecta este grupo al cluster de arriba.
  node_locations = var.node_locations

  # Escalado automático: el cluster crea o borra servidores según haga falta
  autoscaling {
    min_node_count = var.min_nodes # Mínimo de servidores encendidos.
    max_node_count = var.max_nodes # Máximo de servidores si hay mucha carga.
  }

  # Gestión automática de Google
  management {
    auto_repair  = true # Si un servidor se rompe, Google lo arregla solo.
    auto_upgrade = true # Actualiza la versión de Kubernetes automáticamente.
  }

  # Configuración técnica de las máquinas virtuales (VMs)
  node_config {
    machine_type    = var.machine_type # Tamaño de la CPU y RAM (ej: e2-medium).
    service_account = var.node_sa_email # La identidad (SA) que creaste en el módulo IAM.
    disk_size_gb = 10
    disk_type = "pd-standard"
    
    # Permiso para que los nodos puedan usar los servicios de Google Cloud
    oauth_scopes = [ "https://www.googleapis.com/auth/cloud-platform" ] 
  }
}