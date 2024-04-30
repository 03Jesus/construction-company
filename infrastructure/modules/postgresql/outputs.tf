output "postgresql_server_name" {
    value = "${azurerm_postgresql_server.postgresql.name}.postgres.database.azure.com"
}

output "postgresql_username" {
    value = "${azurerm_postgresql_server.postgresql.administrator_login}@${azurerm_postgresql_server.postgresql.name}"
}

output "postgresql_password" {
    value = local.admin_password
}

output "postgresql_database_projects" {
    value = azurerm_postgresql_database.projects_db.name
}

output "postgresql_database_clients" {
    value = azurerm_postgresql_database.clients_db.name
}