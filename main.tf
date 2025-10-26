terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
    subscription_id = "a8e950ce-d2ec-4dd8-b83c-fab54763ab26"
    client_id       = "e991c861-6de1-461e-aaaa-05ddafc0d670"
    tenant_id       = "23caf8b7-b317-43a6-8c08-869a32335cbe"
    client_secret   = ""
}
resource "azurerm_resource_group" "template" {
  name     = var.rg_name
  location = var.azure_region
}
resource "azurerm_virtual_network" "template" {
  name                = var.vn_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.template.location
  resource_group_name = azurerm_resource_group.template.name
}
resource "azurerm_subnet" "template" {
  name                 = var.sn_name
  resource_group_name  = azurerm_resource_group.template.name
  virtual_network_name = azurerm_virtual_network.template.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_network_interface" "template" {
  name                = var.nic_name
  location            = azurerm_resource_group.template.location
  resource_group_name = azurerm_resource_group.template.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.template.id
    private_ip_address_allocation = "Dynamic"
  }

}
resource "azurerm_windows_virtual_machine" "template" {
  name                = var.ComputerName
  resource_group_name = azurerm_resource_group.template.name
  location            = azurerm_resource_group.template.location
  size                = "Standard_F2"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.template.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

}