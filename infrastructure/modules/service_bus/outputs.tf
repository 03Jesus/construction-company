output "send_policy" {
    value = azurerm_servicebus_queue_authorization_rule.send_policy.primary_connection_string
    sensitive = true
}

output "listen_policy" {
    value = azurerm_servicebus_queue_authorization_rule.listen_policy.primary_connection_string
    sensitive = true
}