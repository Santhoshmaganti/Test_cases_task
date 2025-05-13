provider "azurerm" {
  features {}
}

# Test Case 7: Deploy Server within an existing Resource Group
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Test Case 6: Deploy Server with BYOK enabled
resource "azurerm_key_vault" "cmk_vault" {
  name                        = "cmkvault-${random_string.suffix.result}"
  location                    = data.azurerm_resource_group.main.location
  resource_group_name         = data.azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "create", "get", "list", "wrapKey", "unwrapKey"
    ]
  }
}

resource "azurerm_key_vault_key" "byok" {
  name         = "cmk-key"
  key_vault_id = azurerm_key_vault.cmk_vault.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts     = ["wrapKey", "unwrapKey"]
}

# Test Case 2: Deploy Database with permissions (CosmosDB)
resource "azurerm_cosmosdb_account" "main" {
  name                = "cosmos-${random_string.suffix.result}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location_primary
    failover_priority = 0
  }

  geo_location {
    location          = var.location_secondary
    failover_priority = 1
  }
}

# Test Case 2: Deploy Database with permissions (Redis)
resource "azurerm_redis_cache" "main" {
  name                = "redis-${random_string.suffix.result}"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  capacity            = 1
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = false
}

# Test Case 1: Deploy Server in both regions
# Test Case 5: Deploy Server with HA enabled
resource "azurerm_windows_virtual_machine" "server" {
  count               = 2
  name                = "vm-${count.index}"
  location            = count.index == 0 ? var.location_primary : var.location_secondary
  resource_group_name = data.azurerm_resource_group.main.name
  size                = "Standard_DS1_v2"
  admin_username      = var.vm_admin_username
  admin_password      = var.vm_admin_password

  availability_zone   = "1" # HA (Test Case 5)

  os_disk {
    name                 = "osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_encryption_set_id = azurerm_disk_encryption_set.byok.id  # BYOK (Test Case 6)
  }

  network_interface_ids = [
    azurerm_network_interface.server_nic[count.index].id
  ]
}

resource "azurerm_network_interface" "server_nic" {
  count               = 2
  name                = "nic-${count.index}"
  location            = count.index == 0 ? var.location_primary : var.location_secondary
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Test Case 3: Deploy Server with Databases (implicit via provisioning Cosmos and Redis with VMs)
# Test Case 4: Apply lock to servers and databases
resource "azurerm_management_lock" "server_locks" {
  count      = 2
  name       = "lock-vm-${count.index}"
  scope      = azurerm_windows_virtual_machine.server[count.index].id
  lock_level = "CanNotDelete"
}

resource "azurerm_management_lock" "cosmos_lock" {
  name       = "lock-cosmos"
  scope      = azurerm_cosmosdb_account.main.id
  lock_level = "CanNotDelete"
}

resource "azurerm_management_lock" "redis_lock" {
  name       = "lock-redis"
  scope      = azurerm_redis_cache.main.id
  lock_level = "CanNotDelete"
}

# Networking for VMs
resource "azurerm_virtual_network" "main" {
  name                = "vnet-main"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "default" {
  name                 = "subnet1"
  resource_group_name  = data.azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Test Case 6 (continued): Disk Encryption Set (BYOK)
data "azurerm_client_config" "current" {}

resource "azurerm_disk_encryption_set" "byok" {
  name                = "byok-encryption-set"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  key_vault_key_id    = azurerm_key_vault_key.byok.id

  identity {
    type = "SystemAssigned"
  }
}

# Random suffix for naming uniqueness
resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}
