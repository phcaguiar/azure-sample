terraform {
  backend "azurerm" {
    storage_account_name = "terraformazurestone"
    container_name       = "financialit-sample-tfstates"
    key                  = "financialit-sample.tfstate"
    arm_subscription_id  = "ba5141a2-2132-4e5a-b88d-d61f5a175fbe"
  }
}