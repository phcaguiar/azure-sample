resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.name}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  availability_set_id   = "${var.availability_set_id}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${var.network_interface_ids}"]

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  storage_os_disk {
    name          = "${var.storage_os_disk_name}"
    create_option = "${var.storage_os_disk_create_option}"
  }

  os_profile {
    computer_name  = "${var.os_profile_computer_name}"
    admin_username = "${var.os_profile_admin_username}"
    admin_password = "${var.os_profile_admin_password}"
  }

  os_profile_windows_config {}
}