
data "azurerm_public_ip" "vm1" {
  name                = "${var.environment}-${var.location}-publicip"
  resource_group_name = var.resource_group_name
}

data "azurerm_public_ip" "vm2" {
  name                = "dev-uksouth-publicip"
  resource_group_name = "app-terraform-uk-dev"
}

locals {
  endpoints = [
    {
      name      = "primary"
      priority  = 1
      location  = "westus2"
      target_id = data.azurerm_public_ip.vm1.id
    },
    {
      name      = "secondary"
      priority  = 2
      location  = "uksouth"
      target_id = data.azurerm_public_ip.vm2.id
    }
  ]
}

resource "azurerm_traffic_manager_profile" "tm" {
  name                   = "${var.environment}-${var.location}-trafficmanager"
  resource_group_name    = var.resource_group_name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "${var.environment}-${var.location}-trafficmanager"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/health"
  }
}



resource "azurerm_traffic_manager_azure_endpoint" "endpoint" {
  for_each = { for ep in local.endpoints : ep.name => ep }

  name                = "${var.environment}-${var.location}-trafficendpoint"
  profile_id          = azurerm_traffic_manager_profile.tm.id
  always_serve_enabled = true
  target_resource_id  = each.value.target_id
  priority            = each.value.priority
}
