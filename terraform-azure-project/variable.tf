# ==============================================================================
# ROOT MODULE - variables.tf
# ==============================================================================

variable "resource_group_name" {
  description = "The name of the resource group to create"
  type        = string
  default     = "terraform-infra-rg"
}

variable "location" {
  description = "The Azure region to deploy resources"
  type        = string
  default     = "East US"
}

variable "local_ssh_key_path" {
  description = "Path to the SSH public key for VM access"
  type        = string
  default     = "C:/Users/gautam.gohil/Downloads/multicloud-key/ssh-key-rg.pub"
}