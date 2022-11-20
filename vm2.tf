resource "azurerm_resource_group" "myresgrp" {
  name     = "resource1"
  location = "West Europe"
}
resource "azurerm_virtual_network" "myvnet" {
  name                = "vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = "west Europe"
  resource_group_name = "resource1"
  depends_on = [
    azurerm_resource_group.myresgrp
  ]
}
resource "azurerm_subnet" "mysub" {
  name                 = "mysub1"
  resource_group_name  = "resource1"
  virtual_network_name = "vnet1"
  address_prefixes     = ["10.0.2.0/24"]

  depends_on = [
    azurerm_virtual_network.myvnet
  
    
  ]
}
resource "azurerm_network_security_group" "mynsg" {
  name                = "nsg1"
  location            = "west Europe"
  resource_group_name = "resource1"

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [
    azurerm_resource_group.myresgrp
  ]
}
resource "azurerm_public_ip" "pub" {
    name                = "PublicIp1"
    resource_group_name = "resource1"
    location            = "west Europe"
    allocation_method   = "Dynamic"
  
    tags = {
      environment = "Production"
    }
    depends_on = [
      azurerm_resource_group.myresgrp
    ]
}
resource "azurerm_network_interface" "netinterface" {
    name                = "nic12"
    location             = "west Europe"
    resource_group_name = "resource1"

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.mysub.id
        private_ip_address_allocation = "Dynamic"
      }
      depends_on = [
        azurerm_public_ip.pub,
        azurerm_subnet.mysub
      ]
    
    }


resource "azurerm_virtual_machine" "vm" {
    name                  = "vm1"
    location              = "west Europe"
    resource_group_name   = "resource1"
    network_interface_ids = [azurerm_network_interface.netinterface.id]
    vm_size               = "Standard_DS1_v2"
  
      storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
  depends_on = [
      azurerm_network_interface.netinterface
    ]
}
  