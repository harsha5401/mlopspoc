
provider "azurerm" {
  features {}
subscription_id ="9735d0c7-967d-40b3-becd-d1397f62c5b9"
client_id = "eb9f71da-a8db-48e8-9ded-2a3043458d42"
client_secret = "2af0db4a-87b3-4e34-b2f5-c7fdaf435fc3"
tenant_id = "c1d226ed-7a22-492c-a89e-50154dcb92fe"
}


resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}
