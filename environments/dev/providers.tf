#################################################################################
# 1. BLOQUE TERRAFORM: Requisitos del Sistema
#################################################################################
terraform {
  # Versión de Terraform instalada en tu PC/GitHub Actions. 
  # Impide que alguien con una versión muy antigua (o incompatible) ejecute el código.
  required_version = ">= 1.7.0"

  required_providers {
    # El proveedor "google" es el estándar para la mayoría de recursos (VPC, IAM, GKE).
    google = {
      source  = "hashicorp/google" # Origen oficial del plugin en el Terraform Registry.
      version = "~> 5.25"          # Permite actualizaciones menores (5.26, 5.27) pero no saltar a la 6.0.
    }
    
    # El proveedor "google-beta" es OBLIGATORIO para GKE Autopilot y Shared VPC.
    # Muchos recursos avanzados de Google solo están disponibles aquí primero.
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.25"
    }
  }
}

#################################################################################
# 2. CONFIGURACIÓN DE LOS PROVIDERS: La Conexión
#################################################################################

# Configuración para el proveedor estándar
provider "google" {
  project = var.project_id  # ID del proyecto donde se ejecutarán los cambios por defecto.
  region  = var.region      # Región por defecto (ej: europe-west1).
}

# Configuración para el proveedor Beta
# Se configura igual que el anterior, pero Terraform lo usará cuando un recurso
# lo pida explícitamente (como el cluster de Autopilot).
provider "google-beta" {
  project = var.project_id
  region  = var.region
}