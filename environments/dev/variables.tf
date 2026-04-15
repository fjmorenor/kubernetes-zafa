variable "project_id"{
    type = string
}

variable "region"{
    type = string
}

variable "host_project_id" {
    type = string
}

variable "vpc_self_link" {
    type = string
}

variable "subnet_standard_self_link" {
    type = string
}

variable "subnet_autopilot_self_link" {
    type = string
}

variable "node_locations" {
    type = list(string)
    default = [ ]
}

variable "vpc_name" {
    type = string
}

variable "sa_id" {
    type = string
}