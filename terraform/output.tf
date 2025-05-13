output "cosmosdb_account_name" {
  value = azurerm_cosmosdb_account.main.name
}

output "redis_cache_name" {
  value = azurerm_redis_cache.main.name
}

output "vm_names" {
  value = [for vm in azurerm_windows_virtual_machine.server : vm.name]
}
