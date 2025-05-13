# General Azure Configuration
variable "resource_group_name" {
  description = "Name of the existing Azure Resource Group"
  type        = string
  # Test Case 7: Deploy into existing Resource Group
}

variable "location_primary" {
  description = "Primary Azure region"
  type        = string
  default     = "East US"
  # Test Case 1: Primary region for VM and DB deployment
}

variable "location_secondary" {
  description = "Secondary Azure region for redundancy"
  type        = string
  default     = "West US"
  # Test Case 1: Secondary region (for HA + multi-region)
}

# VM Configuration
variable "vm_admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
  default     = "adminuser"
}

variable "vm_admin_password" {
  description = "Admin password for the virtual machine"
  type        = string
  sensitive   = true
}

# Optional: If you want to manage your own suffix
variable "name_suffix" {
  description = "Optional suffix for globally unique resource naming"
  type        = string
  default     = ""
}

# Future Enhancement: For role-based access to CosmosDB/Redis (Test Case 2)
# You can expand this section to include:
# - object_ids for users, services
# - custom role definitions
