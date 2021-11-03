# ---------------------------------------------------------------------------
# Cluster Resource Group
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location
}
# ---------------------------------------------------------------------------
# AKS Cluster Network
# ---------------------------------------------------------------------------

module "aks_network" {
  source              = "../modules/aks_network"
  subnet_name         = var.subnet_name
  vnet_name           = var.vnet_name
  resource_group_name = azurerm_resource_group.aks.name
  subnet_cidr         = var.subnet_cidr
  location            = var.location
  address_space       = var.address_space
}

# ---------------------------------------------------------------------------
# AKS IDs
# ---------------------------------------------------------------------------

module "aks_identities" {
  source              = "../modules/aks_identities"
  cluster_name        = var.cluster_name
  resource_group_name = azurerm_resource_group.aks.id

}
# ---------------------------------------------------------------------------
# AKS Log Analytics
# ---------------------------------------------------------------------------

module "log_analytics" {
  source                           = "../modules/log_analytics"
  resource_group_name              = azurerm_resource_group.aks.name
  log_analytics_workspace_location = var.log_analytics_workspace_location
  log_analytics_workspace_name     = var.log_analytics_workspace_name
  log_analytics_workspace_sku      = var.log_analytics_workspace_sku
}

# ---------------------------------------------------------------------------
# AKS Cluster
# ---------------------------------------------------------------------------

module "aks_cluster" {
  source                          = "../modules/aks-cluster"
  cluster_name                    = var.cluster_name
  location                        = var.location
  dns_prefix                      = var.dns_prefix
  resource_group_name             = azurerm_resource_group.aks.name
  api_server_authorized_ip_ranges = var.subnet_cidr
  kubernetes_version              = var.kubernetes_version
  node_count                      = var.node_count
  min_count                       = var.min_count
  max_count                       = var.max_count
  os_disk_size_gb                 = "1028"
  max_pods                        = "110"
  vm_size                         = var.vm_size
  vnet_subnet_id                  = module.aks_network.aks_subnet_id
  client_id                       = module.aks_identities.cluster_client_id
  client_secret                   = data.azurerm_key_vault_secret.client_Secret.value
  diagnostics_workspace_id        = module.log_analytics.azurerm_log_analytics_workspace

  aad_server_app_secret           = data.azurerm_key_vault_secret.AKS_Server_AppSecret.value
  aad_server_app_id               = data.azurerm_key_vault_secret.AKS_Server_AppID.value
  aad_client_app_id               = data.azurerm_key_vault_secret.AKS_Client_AppId.value

  acr_name                        = "DroneShuttles"
  admin_enabled                   = false
  zone_redundancy                 = true
  acr_sku                         = "basic"

}

# ---------------------------------------------------------------------------
# Role assignment
# ---------------------------------------------------------------------------

resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = azurerm_resource_group.aks.id
  role_definition_name             = "AcrPull"
  principal_id                     = module.aks_identities.cluster_client_id
  skip_service_principal_aad_check = true
  
}
# ---------------------------------------------------------------------------
# Data sources
# ---------------------------------------------------------------------------

data "azurerm_subscription" "primary" {
}
data "azurerm_key_vault" "keyvault" {
  name                = var.keyvault_name
  resource_group_name = "Infastructure"
}
data "azurerm_key_vault_secret" "client_Secret" {
  name         = "aksClientSecret"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}
data "azurerm_key_vault_secret" "AKSSP_AppId" {
  name         = "AKSSP-AppID"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}
data "azurerm_key_vault_secret" "AKSSP_AppSecret" {
  name         = "AKSSP-AppSecret"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}
data "azurerm_key_vault_secret" "AKS_Server_AppSecret" {
  name         = "AKS-Server-AppSecret"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}
data "azurerm_key_vault_secret" "AKS_Server_AppID" {
  name         = "AKS-Server-AppID"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}
data "azurerm_key_vault_secret" "AKS_Client_AppId" {
  name         = "AKS-Client-AppId"
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

# ---------------------------------------------------------------------------
# Azure Web services
# ---------------------------------------------------------------------------

/* module "asp" {

  source = "../modules/asp"

  resource_group = var.resource_group_name
  location       = var.location
  zone_redundant = true
} */