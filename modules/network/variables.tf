variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the Virtual Machine will be created."
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be created."
  default     = "East US"
}

variable "environment" {
  type        = string
  description = "The name of the environment where the Virtual Machine will be created."
}

variable "address_space" {
  type        = list(string)
  description = "The address space that will be used for the Virtual Network."
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  type        = list(string)
  description = "The address prefixes to be used for the subnet."
  default     = ["10.0.1.0/24"]
}
