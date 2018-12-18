module "resource_group" {
   source   =  "./modules/rg"
   name     =  "${var.tribe_name}-${var.environment}"
   location =  "${var.location}"
}

module "virtual_network" {
   source                   = "./modules/vnet"
   name                     = "${var.tribe_name}-${var.environment}"
   location                 = "${var.location}"
   resource_group_name      = "${module.resource_group.rg_name}"
   address_space            = "${var.vnet_cidr}"
}

module "private_subnet" {
   source               =  "./modules/subnet"
   name                 =  "${var.tribe_name}-${var.environment}-private"
   virtual_network_name =  "${module.virtual_network.vnet_name}"
   resource_group_name  =  "${module.resource_group.rg_name}"
   address_prefix       =  "${(cidrsubnet(var.vnet_cidr,8,0))}"
}

module "public_subnet" {
   source               =  "./modules/subnet"
   name                 =  "${var.tribe_name}-${var.environment}-public"
   virtual_network_name =  "${module.virtual_network.vnet_name}"
   resource_group_name  =  "${module.resource_group.rg_name}"
   address_prefix       =  "${(cidrsubnet(var.vnet_cidr,8,1))}"
}

module "security_group" {
   source                              =  "./modules/sg"
   name                                =  "${var.tribe_name}-${var.environment}-public"
   location                            =  "${var.location}"
   resource_group_name                 =  "${module.resource_group.rg_name}"
   sg_rule_name                        =  "allow_RDP"
   sg_rule_description                 =  "Allow RDP access"
   sg_rule_priority                    =  "110"
   sg_rule_direction                   =  "Inbound"
   sg_rule_access                      =  "Allow"
   sg_rule_protocol                    =  "Tcp"
   sg_rule_source_port_range           =  "*"
   sg_rule_destination_port_range      =  "3389"
   sg_rule_source_address_prefix       =  "*"
   sg_rule_destination_address_prefix  =  "*"
}

module "avset" {
   source                        =  "./modules/avset"
   dns_name                      =  "${var.tribe_name}"
   location                      =  "${var.location}"
   resource_group_name           =  "${module.resource_group.rg_name}"
   platform_fault_domain_count   =  2
   platform_update_domain_count  =  2
   managed                       =  true
}

module "lbpip" {
   source                        =  "./modules/pip"
   name                          =  "${var.tribe_name}"
   location                      =  "${var.location}"
   resource_group_name           =  "${module.resource_group.rg_name}"
   public_ip_address_allocation  =  "dynamic"
   domain_name_label             =  "${var.tribe_name}"
}

module "lb" {
   source                                          =  "./modules/lb"
   name                                            =  "${var.tribe_name}"
   location                                        =  "${var.location}"
   resource_group_name                             =  "${module.resource_group.rg_name}"
   frontend_ip_configuration_name                  =  "LoadBalancerFrontEnd"
   frontend_ip_configuration_public_ip_address_id  =  "${module.lbpip.lbpip_id}"
}

module "backend_pool" {
   source               =  "./modules/backend_pool"   
   name                 =  "BackendPool1"
   resource_group_name  =  "${module.resource_group.rg_name}"
   loadbalancer_id      =  "${module.lb.lb_id}"
}

module   "lb_rule" {
   source               =  "./modules/lb_rule"   
   name                           = "${var.tribe_name}"   
   resource_group_name            = "${module.resource_group.rg_name}"
   loadbalancer_id                = "${module.lb.lb_id}"
   protocol                       = "tcp"
   frontend_port                  = "80"
   backend_port                   = "80"
   frontend_ip_configuration_name = "LoadBalancerFrontEnd"
   enable_floating_ip             = "false"
   backend_address_pool_id        = "${module.backend_pool.backend_pool_id}"
   idle_timeout_in_minutes        = "5"
   probe_id                       = "${module.lb_probe.lb_probe_id}"
   depends_on                     = "${module.lb_probe.lb_probe_id}"
}

module "lb_probe" {
   source               =  "./modules/lb_probe"
   name                = "${var.tribe_name}"   
   resource_group_name = "${module.resource_group.rg_name}"
   loadbalancer_id     = "${module.lb.lb_id}"
   protocol            = "tcp"
   port                = 80
   interval_in_seconds = 5
   number_of_probes    = 2
}