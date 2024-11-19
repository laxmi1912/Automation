variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the Virtual Machine will be created."
}

variable "environment" {
  type        = string
  description = "The name of the environment where the Virtual Machine will be created."
}

variable "ssh_public_key_file" {
  type        = string
  description = "Path to the SSH public key file."
  default     = "~/.ssh/id_rsa.pub"
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be created."
  default     = "East US"
}

variable "vm_size" {
  type        = string
  description = "The size of the Virtual Machine instance, e.g., Standard_B2s."
  default     = "Standard_B2s"
}


variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources."
  default     = {}
}
