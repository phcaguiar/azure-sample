resource "azurerm_lb_probe" "lb_probe" {
  name                = "${var.name}"  
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${var.loadbalancer_id}"
  protocol            = "${var.protocol}"
  port                = "${var.port}"
  interval_in_seconds = "${var.interval_in_seconds}"
  number_of_probes    = "${var.number_of_probes}"
}