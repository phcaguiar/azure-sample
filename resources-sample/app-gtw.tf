### Generate a certificate

# data "azurerm_client_config" "current" {}

# resource "azurerm_key_vault" "test" {
#   name                = "keyvaultcertexample"
#   location            = "${azurerm_resource_group.test.location}"
#   resource_group_name = "${azurerm_resource_group.test.name}"
#   tenant_id           = "${data.azurerm_client_config.current.tenant_id}"

#   sku {
#     name = "standard"
#   }

#   access_policy {
#     tenant_id = "${data.azurerm_client_config.current.tenant_id}"
#     object_id = "${data.azurerm_client_config.current.service_principal_object_id}"

#     certificate_permissions = [
#       "create",
#       "delete",
#       "deleteissuers",
#       "get",
#       "getissuers",
#       "import",
#       "list",
#       "listissuers",
#       "managecontacts",
#       "manageissuers",
#       "setissuers",
#       "update",
#     ]

#     key_permissions = [
#       "backup",
#       "create",
#       "decrypt",
#       "delete",
#       "encrypt",
#       "get",
#       "import",
#       "list",
#       "purge",
#       "recover",
#       "restore",
#       "sign",
#       "unwrapKey",
#       "update",
#       "verify",
#       "wrapKey",
#     ]

#     secret_permissions = [
#       "backup",
#       "delete",
#       "get",
#       "list",
#       "purge",
#       "recover",
#       "restore",
#       "set",
#     ]
#   }

#   tags {
#     environment = "Production"
#   }
# }

# resource "azurerm_key_vault_certificate" "test" {
#   name      = "generated-cert"
#   vault_uri = "${azurerm_key_vault.test.vault_uri}"

#   certificate_policy {
#     issuer_parameters {
#       name = "Self"
#     }

#     key_properties {
#       exportable = true
#       key_size   = 2048
#       key_type   = "RSA"
#       reuse_key  = true
#     }

#     lifetime_action {
#       action {
#         action_type = "AutoRenew"
#       }

#       trigger {
#         days_before_expiry = 30
#       }
#     }

#     secret_properties {
#       content_type = "application/x-pkcs12"
#     }

#     x509_certificate_properties {
#       # Server Authentication = 1.3.6.1.5.5.7.3.1
#       # Client Authentication = 1.3.6.1.5.5.7.3.2
#       extended_key_usage = [ "1.3.6.1.5.5.7.3.1" ]

#       key_usage = [
#         "cRLSign",
#         "dataEncipherment",
#         "digitalSignature",
#         "keyAgreement",
#         "keyCertSign",
#         "keyEncipherment",
#       ]

#       subject_alternative_names {
#         dns_names = ["internal.contoso.com", "domain.hello.world"]
#       }

#       subject            = "CN=hello-world"
#       validity_in_months = 12
#     }
#   }
# }

### Import a certificate

# resource "azurerm_key_vault_certificate" "test" {
#   name      = "imported-cert"
#   vault_uri = "${azurerm_key_vault.test.vault_uri}"

#   certificate {
#     contents = "${base64encode(file("certificate-to-import.pfx"))}"
#     password = ""
#   }

#   certificate_policy {
#     issuer_parameters {
#       name = "Self"
#     }

#     key_properties {
#       exportable = true
#       key_size   = 2048
#       key_type   = "RSA"
#       reuse_key  = false
#     }

#     secret_properties {
#       content_type = "application/x-pkcs12"
#     }
#   }
# }



# resource "azurerm_key_vault_certificate" "test" {
#   name      = "imported-cert"
#   vault_uri = "https://stone-key-vault-cert.vault.azure.net/"

#   certificate {
#     contents = "${base64encode(file("certs/financialit.pfx"))}"
#     password = "inicio@1"
#   }

#   certificate_policy {
#     issuer_parameters {
#       name = "Self"
#     }

#     key_properties {
#       exportable = true
#       key_size   = 2048
#       key_type   = "RSA"
#       reuse_key  = false
#     }

#     secret_properties {
#       content_type = "application/x-pkcs12"
#     }
#   }
# }

resource "azurerm_public_ip" "agpip" {
  name                         = "${var.tribe_name}-ag"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg_tribe.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "${var.lb_ip_dns_name}-2"
}


resource "azurerm_application_gateway" "application-gateway" {
  name                = "${var.tribe_name}-${var.environment}"
  resource_group_name = "${azurerm_resource_group.rg_tribe.name}"
  location            = "${var.location}"

  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 2
  }

  waf_configuration {
    enabled          = "true"
    firewall_mode    = "Detection"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"
  }

  gateway_ip_configuration {
    name      = "subnet"
    subnet_id = "${azurerm_subnet.int-subnet.id}"
  }

  frontend_port {
    name = "http"
    port = 80
#    name = "https"
#    port = 443    
  }

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = "${azurerm_public_ip.agpip.id}"
  }

  backend_address_pool {
    name        = "AppService"
#    "fqdn_list" = ["${azurerm_lb_backend_address_pool.backend_pool.id}"]
  }

  http_listener {
    name                           = "http"
    #name                           = "https"
    frontend_ip_configuration_name = "frontend"
    frontend_port_name             = "http"
    #frontend_port_name             = "https"
    protocol                       = "Http"
    #protocol                       = "Http"
#    ssl_certificate_name           = "${azurerm_key_vault_certificate.test.id}"
  }

  probe {
    name                = "probe"
    protocol            = "http"
    #protocol            = "https"
    path                = "/"
    host                = "financialit.centralus.cloudapp.azure.com"
    interval            = "30"
    timeout             = "30"
    unhealthy_threshold = "3"
  }

  backend_http_settings {
    name                  = "http"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
    probe_name            = "probe"
  }

  request_routing_rule {
    name                       = "http"
    #name                       = "https"
    rule_type                  = "Basic"
    http_listener_name         = "http"
    #http_listener_name         = "https"
    backend_address_pool_name  = "AppService"
    backend_http_settings_name = "http"
  }
}