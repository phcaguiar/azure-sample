resource "azurerm_lb" "lb" {
  name                = "${var.name}"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"

  frontend_ip_configuration {
    name                 = "${var.frontend_ip_configuration_name}"
    public_ip_address_id = "${var.frontend_ip_configuration_public_ip_address_id}"
  }
}
