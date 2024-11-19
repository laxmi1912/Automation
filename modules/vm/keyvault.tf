data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                        = "${var.environment}-${var.location}-keyvault"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  soft_delete_retention_days  = 90
  enabled_for_disk_encryption = true

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "Get",
      "Create",
      "Delete",
      "List",
      "Update",
      "Import",
      "Backup",
      "SetRotationPolicy",
      "GetRotationPolicy",
      "WrapKey",
      "UnwrapKey",
      "Decrypt"
    ]
    secret_permissions = ["Get", "Set", "Delete", "List"]
  }

  tags = var.tags
}

resource "azurerm_key_vault_secret" "ssh_public_key" {
  depends_on   = [azurerm_key_vault.keyvault]
  name         = "${var.environment}-${var.location}-vm-publickey"
  value        = file(var.ssh_public_key_file)
  key_vault_id = azurerm_key_vault.keyvault.id

  tags = var.tags
}


resource "azurerm_key_vault_key" "cmk" {
  depends_on = [azurerm_key_vault.keyvault]
  name       = "${var.environment}-${var.location}-customkey1"
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ]
  key_vault_id = azurerm_key_vault.keyvault.id
  key_type     = "RSA"
  key_size     = 2048
  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
}

resource "azurerm_disk_encryption_set" "disk_encryption" {
  depends_on          = [azurerm_key_vault.keyvault]
  name                = "DiskEncryption"
  location            = var.location
  resource_group_name = var.resource_group_name
  key_vault_key_id    = azurerm_key_vault_key.cmk.id

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
