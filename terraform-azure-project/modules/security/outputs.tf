# ==============================================================================
# MODULE: SECURITY - outputs.tf
# ==============================================================================

output "web_nsg_id" {
  value = azurerm_network_security_group.web_nsg.id
}

output "db_nsg_id" {
  value = azurerm_network_security_group.db_nsg.id
}

output "vm_identity_id" {
  value = azurerm_user_assigned_identity.vm_identity.id
}