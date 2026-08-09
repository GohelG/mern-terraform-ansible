# ==============================================================================
# ROOT MODULE - outputs.tf
# ==============================================================================

output "web_server_public_ip" {
  description = "The public IP of the web server"
  value       = module.vm.web_server_public_ip
}