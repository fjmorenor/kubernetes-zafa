variable "instance_name" {
    type = string
}

variable "region" {
    type = string
    default = "europe-west1"
}

variable "user_name" {
    type = string
}

variable "user_password" {
    type = string
    sensitive = true
}

variable "tier" {
    type = string
    default = "db-f1-micro"
}

variable "db_name" {
    type = string
}