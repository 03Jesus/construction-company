resource "azurerm_resource_group" "construction-company-rg" {
    name = var.resource_group_name
    location = var.resource_group_location
}

module "postgresql" {
    source = "./modules/postgresql"
    resource_group_name = azurerm_resource_group.construction-company-rg.name
    location = azurerm_resource_group.construction-company-rg.location
    postgresql_server_name = var.postgresql_server_name
    postgresql_server_username = var.postgresql_server_username
    postgresql_server_password = var.postgresql_server_password
}

module "service_bus" {
    source = "./modules/service_bus"
    rg_name = azurerm_resource_group.construction-company-rg.name
    location = azurerm_resource_group.construction-company-rg.location
    service_bus_namespace_name = var.service_bus_namespace_name
}

module "acr" {
    source = "./modules/acr"
    rg_name = azurerm_resource_group.construction-company-rg.name
    location = azurerm_resource_group.construction-company-rg.location
    acr_name = var.acr_name
}