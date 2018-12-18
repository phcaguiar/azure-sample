resource "azurerm_resource_group" "rg_tribe" {
  name      = "${var.tribe_name}-${var.environment}"
  location  = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.tribe_name}-${var.environment}"
  location            = "${var.location}"
  address_space       = ["${var.vnet_cidr}"]
  resource_group_name = "${azurerm_resource_group.rg_tribe.name}"
}

resource "azurerm_subnet" "subnet_app_1" {
  name                  = "${var.tribe_name}-${var.environment}-app-1"
  virtual_network_name  = "${azurerm_virtual_network.vnet.name}"
  resource_group_name   = "${azurerm_resource_group.rg_tribe.name}"
  address_prefix        = "${(cidrsubnet(var.vnet_cidr,8,0))}"
}

resource "azurerm_subnet" "subnet_app_2" {
  name                  = "${var.tribe_name}-${var.environment}-app-2"
  virtual_network_name  = "${azurerm_virtual_network.vnet.name}"
  resource_group_name   = "${azurerm_resource_group.rg_tribe.name}"
  address_prefix        = "${(cidrsubnet(var.vnet_cidr,8,1))}"
}