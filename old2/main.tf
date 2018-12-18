# Create a Network Security Group with some rules
resource "azurerm_network_security_group" "sg" {
  name                = "${var.tribe_name}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg_tribe.name}"

  security_rule {
    name                       = "allow_RDP"
    description                = "Allow RDP access"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_wirm"
    description                = "Allow winrm access"
    priority                   = 111
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_availability_set" "avset" {
  name                         = "${var.dns_name}avset"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg_tribe.name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_public_ip" "lbpip" {
  name                         = "${var.tribe_name}-ip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg_tribe.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "${var.lb_ip_dns_name}"
}

resource "azurerm_lb" "lb" {
  resource_group_name = "${azurerm_resource_group.rg_tribe.name}"
  name                = "${var.tribe_name}lb"
  location            = "${var.location}"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = "${azurerm_public_ip.lbpip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  resource_group_name = "${azurerm_resource_group.rg_tribe.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "BackendPool1"
}

# resource "azurerm_lb_nat_rule" "tcp" {
#   resource_group_name            = "${azurerm_resource_group.rg_tribe.name}"
#   loadbalancer_id                = "${azurerm_lb.lb.id}"
#   name                           = "RDP-VM-${count.index}"
#   protocol                       = "tcp"
#   frontend_port                  = "5000${count.index + 1}"
#   backend_port                   = 3389
#   frontend_ip_configuration_name = "LoadBalancerFrontEnd"
#   count                          = 2
# }

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name            = "${azurerm_resource_group.rg_tribe.name}"
  loadbalancer_id                = "${azurerm_lb.lb.id}"
  name                           = "LBRule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.backend_pool.id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${azurerm_lb_probe.lb_probe.id}"
  depends_on                     = ["azurerm_lb_probe.lb_probe"]
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name = "${azurerm_resource_group.rg_tribe.name}"
  loadbalancer_id     = "${azurerm_lb.lb.id}"
  name                = "tcpProbe"
  protocol            = "tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_network_interface" "nic_0" {
  name                = "${var.tribe_name}-${count.index}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg_tribe.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"

  ip_configuration {
    name                                    = "ipconfig0"
    subnet_id                               = "${azurerm_subnet.ext-subnet.id}"
    private_ip_address_allocation           = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
#    load_balancer_inbound_nat_rules_ids     = ["${element(azurerm_lb_nat_rule.tcp.*.id, count.index)}"]
  }
}

resource "azurerm_network_interface" "nic_1" {
  name                = "${var.tribe_name}-1"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg_tribe.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.ext-subnet.id}"
    private_ip_address_allocation           = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
#    load_balancer_inbound_nat_rules_ids     = ["${element(azurerm_lb_nat_rule.tcp.*.id, count.index)}"]
  }
}

resource "azurerm_virtual_machine" "vm0" {
  name                  = "vm-${var.tribe_name}-0"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg_tribe.name}"
  availability_set_id   = "${azurerm_availability_set.avset.id}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = "${azurerm_network_interface.nic_0.id}"

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name          = "osdisk0"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_windows_config {}
}


resource "azurerm_virtual_machine" "vm1" {
  name                  = "vm-${var.tribe_name}-1"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg_tribe.name}"
  availability_set_id   = "${azurerm_availability_set.avset.id}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = "${azurerm_network_interface.nic_1.id}"

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name          = "osdisk1"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_windows_config {}
}



resource "azurerm_public_ip" "public_ip_0" {
  name                         = "public-ip-${var.tribe_name}-0"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg_tribe.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "${var.lb_ip_dns_name}-0"
}

resource "azurerm_public_ip" "public_ip_1" {
  name                         = "public-ip-${var.tribe_name}-1"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg_tribe.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "${var.lb_ip_dns_name}-1"
}


resource "azurerm_network_interface" "ext-nic_0" {
  name                      = "ext-nic-${var.tribe_name}-0"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.rg_tribe.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.ext-subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.public_ip_0.id}"
  }
}

resource "azurerm_network_interface" "ext-nic-1" {
  name                      = "ext-nic-${var.tribe_name}-1"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.rg_tribe.name}"
  network_security_group_id = "${azurerm_network_security_group.sg.id}"

  ip_configuration {
    name                          = "primary"
    subnet_id                     = "${azurerm_subnet.ext-subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.public_ip_1.id}"
  }
}