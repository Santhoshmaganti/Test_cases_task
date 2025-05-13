# Output values for deployed infrastructure

output "vm_ids" {
  description = "IDs of the deployed virtual machines"
  value       = azurerm_windows_virtual_machine.server[*].id
  # Test Case 1, 5, 6, 7: Multi-region, HA, BYOK, existing RG
}

output "vm_ips" {
  description = "Private IPs of the virtual machines"
  value       = azurerm_network_interface.server_nic[*].ip_configuration[0].private_ip_address
  # Test Case 1: For verifying cross-region deployment
}

output "cosmosdb_endpoint" {
  description = "Cosmos DB endpoint URI"
  value       = azurerm_cosmosdb_account.main.endpoint
  # Test Case 2: Database access output
}

output "redis_host" {
  description = "Redis host name"
  value       = azurerm_redis_cache.main.hostname
  # Test Case 2: Redis output
}

output "key_vault_uri" {
  description = "Key Vault URI for BYOK"
  value       = azurerm_key_vault.cmk_vault.vault_uri
  # Test Case 6: BYOK support reference
}
