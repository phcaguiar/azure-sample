resource "azurerm_network_interface" "nic" {
  name                = "${var.name}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  network_security_group_id = "${var.network_security_group_id}"

  ip_configuration {
    name                                    = "${var.ip_configuration_name}"
    subnet_id                               = "${var.ip_configuration_subnet_id}"
    private_ip_address_allocation           = "${var.ip_configuration_private_ip_address_allocation}"
    load_balancer_backend_address_pools_ids = ["${var.ip_configuration_load_balancer_backend_address_pools_ids}"]
#    load_balancer_inbound_nat_rules_ids     = ["${var.ip_configuration_load_balancer_inbound_nat_rules_ids}"]
  }
}