terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.115"
    }
  }
  required_version = ">= 1.9"
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}
