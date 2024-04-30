resource "azurerm_api_management" "construction_company_api_managment" {
    name                = "construction-company-api-managment"
    location            = var.location
    resource_group_name = var.resource_group_name
    publisher_email     = var.api_managment_email
    publisher_name      = "Construction Company UTB"
    sku_name            = "Consumption_0"
}