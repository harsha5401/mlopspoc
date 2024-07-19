terraform {
  backend "azurerm" {
    storage_account_name = "myterraformstorageaccount"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    resource_group_name  = RGNAMEmlops20july
  }
}
provider "azurerm" {
  features {}
subscription_id ="9735d0c7-967d-40b3-becd-d1397f62c5b9"
client_id = "eb9f71da-a8db-48e8-9ded-2a3043458d42"
client_secret = "TQP8Q~j8_tPEe_UOvxPOY1Y50YESBQHGMdHP.cJB"
tenant_id = "c1d226ed-7a22-492c-a89e-50154dcb92fe"
}

resource "azurerm_resource_group" "default" {
  name     = var.rgname
  location = var.location
}
resource "azurerm_application_insights" "default" {
  name                = "${var.ml}-appi"
  location            = var.location
  resource_group_name = var.rgname
  application_type    = "web"
}

resource "azurerm_key_vault" "default" {
  name                     = "${var.ml}kv"
  location                 = var.location
  resource_group_name      = var.rgname
  tenant_id                = "c1d226ed-7a22-492c-a89e-50154dcb92fe"
  sku_name                 = "premium"
  purge_protection_enabled = false
}

resource "azurerm_storage_account" "default" {
  name                            = "${var.ml}st"
  location                        = var.location
  resource_group_name             = var.rgname
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  allow_nested_items_to_be_public = false
}

// resource "azurerm_container_registry" "default" {
//   name                = "${var.ml}cr"
//   location            = var.location
//   resource_group_name = var.rgname
//   sku                 = "Premium"
//   admin_enabled       = true
// }

# Machine Learning workspace
resource "azurerm_machine_learning_workspace" "default" {
  name                          = var.ml
  location                      = var.location
  resource_group_name           = var.rgname
  application_insights_id       = azurerm_application_insights.default.id
  key_vault_id                  = azurerm_key_vault.default.id
  storage_account_id            = azurerm_storage_account.default.id
  // container_registry_id         = azurerm_container_registry.default.id
  public_access_behind_virtual_network_enabled = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "mlops-vnet1"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = var.rgname
}
 
resource "azurerm_subnet" "example" {
  name                 = "mlops-subnet1"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.1.0.0/24"]
}
 
resource "azurerm_machine_learning_compute_cluster" "test" {
  name                          = "cpu-cluster"
  location                      = var.location
  vm_priority                   = "LowPriority"
  vm_size                       = "Standard_DS2_v2"
  machine_learning_workspace_id = azurerm_machine_learning_workspace.default.id
  subnet_resource_id            = azurerm_subnet.example.id
 
  scale_settings {
    min_node_count                       = 0
    max_node_count                       = 1
    scale_down_nodes_after_idle_duration = "PT30S" # 30 seconds
  }
 
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "storage_contributor_role" {
  scope                = azurerm_storage_account.default.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_machine_learning_compute_cluster.test.identity[0].principal_id
}

resource "azurerm_role_assignment" "data_scientist_role" {
  scope                = azurerm_machine_learning_workspace.default.id
  role_definition_name = "AzureML Data Scientist"
  principal_id         = azurerm_machine_learning_compute_cluster.test.identity[0].principal_id
}
