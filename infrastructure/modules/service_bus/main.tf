resource "azurerm_servicebus_namespace" "sb_namespace" {
    name = var.service_bus_namespace_name
    location = var.location
    resource_group_name = var.rg_name
    sku = "Basic"
}

resource "azurerm_servicebus_queue" "sb_queue" {
    name = "client-registered"
    namespace_id = azurerm_servicebus_namespace.sb_namespace.id
}

resource "azurerm_servicebus_queue_authorization_rule" "send_policy" {
    name = "send-client-notification-email"
    queue_id = azurerm_servicebus_queue.sb_queue.id

    listen = false
    send = true
    manage = false
}

resource "azurerm_servicebus_queue_authorization_rule" "listen_policy" {
    name = "receive-client-notification-email"
    queue_id = azurerm_servicebus_queue.sb_queue.id

    listen = true
    send = false
    manage = false
}