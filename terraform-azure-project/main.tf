# ==============================================================================
# ROOT MODULE - main.tf
# ==============================================================================


# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create a virtual network and subnets
module "vnet" {
  source              = "./modules/vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Create the public IP associated with the web server
resource "azurerm_public_ip" "web_pip" {
  name                = "web-server-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create security groups and assign rules
module "security" {
  source              = "./modules/security"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_id             = module.vnet.vnet_id
  my_public_ip        = azurerm_public_ip.web_pip.ip_address

  depends_on = [azurerm_public_ip.web_pip]
}

# Create virtual machines
module "vm" {
  source              = "./modules/vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  public_subnet_id    = module.vnet.public_subnet_id
  private_subnet_id   = module.vnet.private_subnet_id
  web_nsg_id          = module.security.web_nsg_id
  db_nsg_id           = module.security.db_nsg_id
  vm_identity_id      = module.security.vm_identity_id
  local_ssh_key_path  = var.local_ssh_key_path
  public_ip_id        = azurerm_public_ip.web_pip.id
}