module "provider" {
   source        =   "git::https://github.com/phcaguiar/terraform-az-provider.git?ref=v1.0.0"
   subscription  =   "${var.subscription_id}"
}

module "resource_group" {
   source               =   "git::https://github.com/phcaguiar/terraform-az-resource-group.git?ref=v1.0.0"
   resource_group_name  =   "${var.project_name}-${var.environment}"
   location             =   "${var.location}"
   tag_team             =   "${var.project_name}"
}

# module "iam" {
#    source   =   "git::https://github.com/phcaguiar/terraform-az-iam.git?ref=v1.0.0"
# }

module "virtual_network" {
   source                   =   "git::https://github.com/phcaguiar/terraform-az-virtual-network.git?ref=v1.0.1"
   virtual_network_name     =   "${var.project_name}-${var.environment}"
   location                 =   "${var.location}"
   azure_resource_group     =   "${module.resource_group.azure_resource_group}"
   vnet_cidr                =   "${var.vnet_cidr}"
   virtual_subnet_name_1    =   "${var.project_name}-${var.environment}-1"
   virtual_subnet_name_2    =   "${var.project_name}-${var.environment}-2"
   tag_team                 =   "${var.project_name}"  
}

# module "storage" {
#    source               =   "git::https://github.com/phcaguiar/terraform-az-storage-account.git?ref=v1.0.0"
#    storage_name         =   "${var.project_name}${var.environment}${var.location}"
#    azure_resource_group =   "${module.resource_group.azure_resource_group}"
#    location             =   "${var.location}"
#    tag_team             =   "${var.project_name}"
# }

module "subnet_1" {
   source                   =   "git::https://github.com/phcaguiar/terraform-az-subnet.git?ref=v1.0.1"
   subnet_name              =   "${var.project_name}-${var.environment}-1"
   virtual_network_name     =   "${module.virtual_network.virtual_network_name}"
   azure_resource_group     =   "${module.resource_group.azure_resource_group}"
   subnet_prefixe           =   "${(cidrsubnet(var.vnet_cidr,8,0))}"
}

module "subnet_2" {
   source                   =   "git::https://github.com/phcaguiar/terraform-az-subnet.git?ref=v1.0.1"
   subnet_name              =   "${var.project_name}-${var.environment}-2"
   virtual_network_name     =   "${module.virtual_network.virtual_network_name}"
   azure_resource_group     =   "${module.resource_group.azure_resource_group}"
   subnet_prefixe           =   "${(cidrsubnet(var.vnet_cidr,8,1))}"
}