output "key_vault_id" {
  value       = azurerm_key_vault.keyvault.id
  description = "The ID of the Azure Key Vault."
}

output "key_id" {
  value       = azurerm_key_vault_key.cmk.id
  description = "The ID of the customer-managed key."
}

output "disk_encryption_set_id" {
  value       = azurerm_disk_encryption_set.disk_encryption.id
  description = "The ID of the Disk Encryption Set."
}

output "vm_id" {
  value       = azurerm_linux_virtual_machine.vm.id
  description = "The ID of the VM"
}

output "vm_public_ip" {
  value       = azurerm_linux_virtual_machine.vm.public_ip_address
  description = "The public IP address of the VM"
}

output "vm_private_ip" {
  value       = azurerm_linux_virtual_machine.vm.private_ip_address
  description = "The private IP address of the VM"
}

output "vm_admin_username" {
  value       = azurerm_linux_virtual_machine.vm.admin_username
  description = "The admin username of the VM"
}

