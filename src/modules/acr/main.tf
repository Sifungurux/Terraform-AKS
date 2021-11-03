resource "azurerm_resource_group" "acr_rg" {
  name     = var.rg_acr_name
  location = var.rg_acr_location
}

resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = "${module.aks_cluster.azurerm_kubernetes_cluster.kubelet_identity}"
  skip_service_principal_aad_check = true
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.acr_rg.name
  location            = azurerm_resource_group.acr_rg.location
  sku                 = var.acr_sku
  admin_enabled       = var.admin_enabled

  /* georeplications = [
    {
      location                = var.avil_loc_1
      zone_redundancy_enabled = var.zone_redundancy
      tags                    = {}
    },
    {
      location                = var.avil_loc_2
      zone_redundancy_enabled = var.zone_redundancy
      tags                    = {}
  }] */
}

