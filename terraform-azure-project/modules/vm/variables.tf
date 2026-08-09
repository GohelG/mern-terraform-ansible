# ==============================================================================
# MODULE: VM - variables.tf
# ==============================================================================

variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "public_subnet_id" { type = string }
variable "private_subnet_id" { type = string }
variable "web_nsg_id" { type = string }
variable "db_nsg_id" { type = string }
variable "vm_identity_id" { type = string }
variable "local_ssh_key_path" { type = string }
variable "public_ip_id" { type = string }