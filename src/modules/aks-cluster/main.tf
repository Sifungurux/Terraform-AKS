resource "azurerm_kubernetes_cluster" "cluster" {
  name                            = var.cluster_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  dns_prefix                      = var.dns_prefix
  kubernetes_version              = var.kubernetes_version
  private_cluster_enabled         = true

  default_node_pool {
    name            = var.default_pool_name
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_size_gb = var.os_disk_size_gb
    vnet_subnet_id  = var.vnet_subnet_id
    max_pods        = var.max_pods
    type            = var.default_pool_type
    
    availability_zones  = ["1", "2"]
    enable_auto_scaling = true
    min_count           = var.min_count
    max_count           = var.max_count

    tags = merge(
      {
        "environment" = "dronecloud"
      },
      {
        "aadssh" = "True"
      },
    )
  }


  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = "calico"
    service_cidr       = var.service_cidr
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }
  
   
  addon_profile {
    http_application_routing {
      enabled = true
    }
    azure_policy {
      enabled = true
     }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.diagnostics_workspace_id
    }
  }
  role_based_access_control {
    enabled           = true

    azure_active_directory {
      client_app_id       = var.aad_client_app_id
      server_app_id       = var.aad_server_app_id
      server_app_secret   = var.aad_server_app_secret
      tenant_id           = var.tenant_id

    }

  }
 tags = {
        Environment = "Development"
    }

  lifecycle {
    prevent_destroy = false
  }
}


resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = var.admin_enabled
}

resource "azurerm_monitor_diagnostic_setting" "aks_cluster" {
  name                       = "${azurerm_kubernetes_cluster.cluster.name}-audit"
  target_resource_id         = azurerm_kubernetes_cluster.cluster.id
  log_analytics_workspace_id = var.diagnostics_workspace_id

  log {
    category = "kube-apiserver"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "kube-controller-manager"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "kube-scheduler"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "kube-audit"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
}