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