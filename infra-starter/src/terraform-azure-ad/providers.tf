terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.39.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.60.0"
    }
  }

  backend "local" {}
}

provider "azurerm" {
  features {}
}
