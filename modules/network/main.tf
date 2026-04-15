# ----------------------------------------------------------------------------------
# ARCHIVO: modules/network/main.tf
# OBJETIVO: Definir la infraestructura de red base (VPC y Subredes)
# ----------------------------------------------------------------------------------

# PASO 1: Crear la VPC (La red global vacía)
# La VPC es el "contenedor" principal de toda tu red privada.
resource "google_compute_network" "vpc" {
    name                    = var.vpc_name   # El nombre de la red (ej: vpc-kubernetes)[cite: 77].
    project                 = var.project_id # El ID del proyecto HOST que es el dueño de la red[cite: 77].
    
    # IMPORTANTE: Ponemos false para que GCP no cree subredes automáticas. 
    # Esto nos da control total sobre las IPs (modo producción)[cite: 77].
    auto_create_subnetworks = false 
    
    # REGIONAL significa que los recursos de esta red se gestionan por región[cite: 121].
    routing_mode            = "REGIONAL"
}

# PASO 2: Subred para el Cluster GKE Standard
# Definimos la "planta" donde vivirán los nodos del cluster Standard.
resource "google_compute_subnetwork" "subnet_standard" {
   project       = var.project_id              # Proyecto donde se crea la subred[cite: 77].
   name          = "subnet-gke-standard"       # Nombre único de la subred[cite: 147].
   ip_cidr_range = "10.10.0.0/24"              # Rango de IPs para los servidores (nodos)[cite: 147].
   region        = var.region                  # Ubicación física (ej: europe-west1)[cite: 77].
   network       = google_compute_network.vpc.id # Conecta esta subred a la VPC creada arriba[cite: 77].

   # Permite que recursos sin IP pública (nodos privados) lleguen a las APIs de Google[cite: 77].
   private_ip_google_access = true

   # RANGOS SECUNDARIOS: GKE los necesita obligatoriamente para los Pods y Servicios.
   secondary_ip_range {
     range_name    = "pods-standard"           # Nombre del rango para los contenedores (Pods)[cite: 147].
     ip_cidr_range = "10.20.0.0/16"            # Rango amplio (65.536 IPs) para muchos Pods[cite: 147].
   } 

   secondary_ip_range {
     range_name    = "service-standard"        # Nombre del rango para los servicios internos[cite: 147].
     ip_cidr_range = "10.30.0.0/20"            # Rango para la comunicación interna entre apps[cite: 147].
   }
}

# PASO 3: Subred para el Cluster GKE Autopilot
# Definimos una planta separada para que el Autopilot no choque con el Standard[cite: 147].
resource "google_compute_subnetwork" "subnet_autopilot" {
    project       = var.project_id
    name          = "subnet-gke-autopilot"     # Nombre diferente para identificarlo[cite: 147].
    ip_cidr_range = "10.11.0.0/24"             # Rango de IPs distinto (10.11.x.x)[cite: 147].
    region        = var.region
    network       = google_compute_network.vpc.id

    private_ip_google_access = true

    # RANGOS SECUNDARIOS: Autopilot también necesita sus propios espacios aislados[cite: 147].
    secondary_ip_range {
        range_name    = "pods-autopilot"       # Rango de IPs para los Pods de Autopilot[cite: 147].
        ip_cidr_range = "10.40.0.0/16"
    }

    secondary_ip_range {
        range_name    = "services-autopilot"   # Rango de IPs para los servicios de Autopilot[cite: 147].
        ip_cidr_range = "10.50.0.0/20"
    }
}