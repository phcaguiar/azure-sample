resource "azurerm_network_security_group" "sg" {
  name                = "${var.name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  security_rule {
    name                       = "${var.sg_rule_name}"
    description                = "${var.sg_rule_description}"
    priority                   = "${var.sg_rule_priority}"
    direction                  = "${var.sg_rule_direction}"
    access                     = "${var.sg_rule_access}"
    protocol                   = "${var.sg_rule_protocol}"
    source_port_range          = "${var.sg_rule_source_port_range}"
    destination_port_range     = "${var.sg_rule_destination_port_range}"
    source_address_prefix      = "${var.sg_rule_source_address_prefix}"
    destination_address_prefix = "${var.sg_rule_destination_address_prefix}"
  }
}