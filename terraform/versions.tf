terraform {
  backend "azurerm" {
    resource_group_name  = var.backend_rg_name
    storage_account_name = var.backend_sa_name
    container_name       = "tfstate"
    key                  = "landingzone.tfstate"
  }
}
