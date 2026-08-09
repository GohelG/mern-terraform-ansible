# ==============================================================================
# MODULE: VM - outputs.tf
# ==============================================================================

output "web_server_public_ip" {
  value       = azurerm_linux_virtual_machine.web_server.public_ip_address
  description = "The public IP address of the web server"
}

output "db_server_public_ip" {
  value       = azurerm_linux_virtual_machine.db_server.public_ip_address
  description = "The public IP address of the database server"
}