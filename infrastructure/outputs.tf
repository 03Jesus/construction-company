output "resource_group_name" {
    value = azurerm_resource_group.construction-company-rg.name
}

output "postgresql_server_name" {
    value = module.postgresql.postgresql_server_name
}

output "postgresql_database_projects" {
    value = module.postgresql.postgresql_database_projects
}

output "postgresql_database_clients" {
    value = module.postgresql.postgresql_database_clients
}

output "postgresql_username" {
    value = module.postgresql.postgresql_username
}

output "postgresql_password" {
    value = module.postgresql.postgresql_password
    sensitive = true
}

output "send_policy" {
    value = module.service_bus.send_policy
    sensitive = true
}

output "listen_policy" {
    value = module.service_bus.listen_policy
    sensitive = true
}

output "acr_name" {
    value = module.acr.acr_name
}
