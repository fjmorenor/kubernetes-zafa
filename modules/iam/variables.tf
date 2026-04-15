variable "project_id" {
    type = string
}

variable "sa_id" {
    description = "Nombre corto de la cuenta (ej: sa-backend)"
    type = string
}

variable "sa_display_name" {
    description = "Nombre legible (ej: Cuenta para el Backend)"
    type = string
}

variable "roles" {
    description = "Lista de llaves/permisos que necesita (ej: [roles/storage.admin])"
    type = list(string)
    default = []
}