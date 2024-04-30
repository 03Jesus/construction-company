variable "resource_group_name" {
    type = string
    description = "The name of the resource group"
}

variable "resource_group_location" {
    type = string
    description = "The location of the resource group"
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

variable "acr_name" {
    type        = string
    description = "ACR name"
}

variable "service_bus_namespace_name" {
    type = string
    description = "Name of the Service Bus namespace"
}

variable "api_managment_email" {
    type = string
    description = "Email for the API Managment"
}