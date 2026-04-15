variable "project_id"{
    type = string
}

variable "mode"{
    type = string
    validation {
        condition = contains (["host", "dev"], var.mode)
        error_message = "mode debe ser host o dev"
    }
}

variable "extra_apis"{
    type = list(string)
    default = []
}