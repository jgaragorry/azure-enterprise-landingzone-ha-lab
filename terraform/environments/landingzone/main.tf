locals {
  tags = {
    Environment   = "lab"
    Project       = "disaster-recovery"
    Owner         = "jgaragorry"
    TTL           = "2026-02-24T17:00:00Z"
    CostCenter    = "training"
    Compliance    = "finops-sre-security"
    ManagedBy     = "terraform"
  }
}

resource "azurerm_resource_group" "workload" {
  name     = "${var.prefix}-rg-workload"
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet-main"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.workload.name
  tags                = local.tags
}

resource "azurerm_subnet" "app" {
  name                 = "${var.prefix}-subnet-app"
  resource_group_name  = azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

output "resource_group_name" {
  value = azurerm_resource_group.workload.name
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}
