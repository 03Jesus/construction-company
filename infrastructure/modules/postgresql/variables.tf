variable "location" {
    type = string
    description = "Location for all resources"
}

variable "resource_group_name" {
    type = string
    description = "Resource group for all resources"
}

variable "postgresql_server_name" {
    type = string
    description = "Name of the PostgreSQL server"
}

variable "postgresql_server_username" {
    type = string
    description = "Username for the PostgreSQL server"
    default = "azureadmin"
}

variable "postgresql_server_password" {
    type = string
    description = "Password for the PostgreSQL server"
}