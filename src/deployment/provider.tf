terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  backend "remote" {
    organization = "KirkDevOps"
    workspaces {
      name = "KirkOPS-Workspace"
    }
  }
}

provider "azuread" {
  tenant_id = var.tenant_id
}
provider "azurerm" {
  features {}
}