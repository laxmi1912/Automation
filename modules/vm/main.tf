data "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "${var.environment}-${var.location}-vm-publickey"
  key_vault_id = azurerm_key_vault.keyvault.id
}

data "azurerm_subnet" "subnet" {
  name = "${var.environment}-${var.location}-subnet"
  virtual_network_name = "${var.environment}-${var.location}-vnet"
  resource_group_name = var.resource_group_name
}

resource "azurerm_public_ip" "publicip" {
  name                = "${var.environment}-${var.location}-publicip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                  = "Standard"

  tags = var.tags
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.environment}-${var.location}-nic1"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "example"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  depends_on          = [azurerm_key_vault_secret.ssh_public_key]
  name                = "${var.environment}-${var.location}-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = "${var.environment}-${var.location}-admin"
  admin_ssh_key {
    username   = "${var.environment}-${var.location}-admin"
    public_key = data.azurerm_key_vault_secret.ssh_public_key.value
  }
  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = var.tags
}
