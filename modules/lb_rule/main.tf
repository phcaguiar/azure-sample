resource "azurerm_lb_rule" "lb_rule" {
  name                           = "${var.name}"  
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${var.loadbalancer_id}"
  protocol                       = "${var.protocol}"
  frontend_port                  = "${var.frontend_port}"
  backend_port                   = "${var.backend_port}"
  frontend_ip_configuration_name = "${var.frontend_ip_configuration_name}"
  enable_floating_ip             = "${var.enable_floating_ip}"
  backend_address_pool_id        = "${var.backend_address_pool_id}"
  idle_timeout_in_minutes        = "${var.idle_timeout_in_minutes}"
  probe_id                       = "${var.probe_id}"
  depends_on                     = []
}