resource "random_password" "admin_password" {
    length      = 20
    special     = true
    min_numeric = 1
    min_upper   = 1
    min_lower   = 1
    min_special = 1
    override_special = "!#$%^&*()_+-=[]{}<>?,."
}

locals {
    admin_password = try(random_password.admin_password.result, var.postgresql_server_password)
}

resource "azurerm_postgresql_server" "postgresql" {
    name                = "construction-company-postgresql"
    resource_group_name = var.resource_group_name
    location            = var.location
    sku_name            = "B_Gen5_1"
    version             = "11"
    administrator_login          = var.postgresql_server_username
    administrator_login_password = local.admin_password
    storage_mb          = 5120
    ssl_enforcement_enabled      = false
    ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
    tags = {
        environment = "dev"
    }
}

resource "azurerm_postgresql_database" "projects_db" {
    name = "construction-company-projects-db"
    server_name = azurerm_postgresql_server.postgresql.name
    resource_group_name = var.resource_group_name
    charset = "UTF8"
    collation = "en-US"

    lifecycle {
        prevent_destroy = true
    }
}

resource "azurerm_postgresql_database" "clients_db" {
    name = "construction-company-clients-db"
    server_name = azurerm_postgresql_server.postgresql.name
    resource_group_name = var.resource_group_name
    charset = "UTF8"
    collation = "en-US"

    lifecycle {
        prevent_destroy = true
    }
}

resource "azurerm_postgresql_firewall_rule" "allow_all" {
    name                = "AllowAll"
    resource_group_name = var.resource_group_name
    server_name         = azurerm_postgresql_server.postgresql.name
    start_ip_address    = "0.0.0.0"
    end_ip_address      = "255.255.255.255"
}
