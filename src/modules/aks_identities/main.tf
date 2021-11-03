# Cluster Identity

resource "azuread_application" "cluster_aks" {
  display_name  = var.cluster_name
}

resource "azuread_service_principal" "cluster_sp" {
  application_id = azuread_application.cluster_aks.application_id

  lifecycle {
    prevent_destroy = true
  }
}

resource "random_string" "cluster_sp_password" {
  length  = 32
  special = true
  keepers = {
    service_principal = azuread_service_principal.cluster_sp.id
  }
}

