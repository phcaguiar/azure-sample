resource "azurerm_api_management" "api_mngmt" {
  name                = "example-apim"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg_tribe.name}"
  publisher_name      = "My Company"
  publisher_email     = "company@terraform.io"

  sku {
    name     = "Developer"
    capacity = 1
  }

  hostname_configuration {
    management  {
        host_name   =   "example-apim"
        key_vault_id    =   "https://example.com.com.br"
    }
  }  
}