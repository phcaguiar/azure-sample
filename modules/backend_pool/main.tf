resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name                = "${var.name}"  
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${var.loadbalancer_id}"
}