resource "azurerm_availability_set" "avset" {
  name                         = "${var.dns_name}"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  platform_fault_domain_count  = "${var.platform_fault_domain_count}"
  platform_update_domain_count = "${var.platform_update_domain_count}"
  managed                      = "${var.managed}"
}