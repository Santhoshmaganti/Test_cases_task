variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
}

variable "location_primary" {
  description = "Primary region"
  type        = string
  default     = "East US"
}

variable "location_secondary" {
  description = "Secondary region"
  type        = string
  default     = "West US"
}

variable "vm_admin_username" {
  default = "azureuser"
}

variable "vm_admin_password" {
  default     = "P@ssw0rd1234!"
  sensitive   = true
}
