# ==============================================================================
# MODULE: VM - main.tf (Corrected)
# ==============================================================================
# Create the public IP associated with the web server
resource "azurerm_public_ip" "web_pip" {
  name                = "web-server-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create network interfaces for the web and database servers
resource "azurerm_network_interface" "web_nic" {
  name                = "web-server-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.public_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }
}

resource "azurerm_network_interface_security_group_association" "web_nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.web_nic.id
  network_security_group_id = var.web_nsg_id
}

resource "azurerm_network_interface" "db_nic" {
  name                = "db-server-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.private_subnet_id
    private_ip_address_allocation = "Dynamic" 
  }
}

resource "azurerm_network_interface_security_group_association" "db_nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.db_nic.id
  network_security_group_id = var.db_nsg_id
}

# Create virtual machines and associate them with the network interfaces and security groups
resource "azurerm_linux_virtual_machine" "web_server" {
  name                = "web-server-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_D2s_v3"
  network_interface_ids = [
    azurerm_network_interface.web_nic.id,
  ]

  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.local_ssh_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.vm_identity_id]
  }
}

resource "azurerm_linux_virtual_machine" "db_server" {
  name                = "db-server-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_D2s_v3"
  network_interface_ids = [
    azurerm_network_interface.db_nic.id,
  ]

  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.local_ssh_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.vm_identity_id]
  }
}