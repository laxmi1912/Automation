
data "azurerm_virtual_machine" "vm1" {
  name                = "dev-eastus2-vm"
  resource_group_name = var.resource_group_name
}

data "azurerm_virtual_machine" "vm2" {
  name                = "dev-eastus-vm"
  resource_group_name = var.resource_group_name
}

locals {
  endpoints = [
    {
      name      = "primary"
      priority  = 1
      location  = "East US"
      target_id = data.azurerm_virtual_machine.vm1.id
    },
    {
      name      = "secondary"
      priority  = 2
      location  = "East US 2"
      target_id = data.azurerm_virtual_machine.vm2.id
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

  name                = random_id.server.hex
  profile_id          = azurerm_traffic_manager_profile.tm.name
  always_serve_enabled = true
  target_resource_id  = each.value.target_id
  priority            = each.value.priority
}
