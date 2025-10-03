provider "aws" {
  region = "us-west-1"
}

# terraform {
#   backend "s3" {
#     bucket         = "tfstate-remote-backend-003-1120"
#     key            = "jupiter/statefile"
#     region         = "us-west-1"
#     dynamodb_table = "jupiter-state-locking"
#     encrypt        = true
#   }
# }

module "vpc" {
  source                    = "./vpc"
  tags                      = local.project_tags
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block
  db_subnet_cidr_block      = var.db_subnet_cidr_block
  availability_zone         = var.availability_zone
}

module "alb" {
  source                           = "./alb"
  vpc_id                           = module.vpc.vpc_id
  apci_jupiter_public_subnet_az_1a = module.vpc.apci_jupiter_public_subnet_az_1a
  apci_jupiter_public_subnet_az_1c = module.vpc.apci_jupiter_public_subnet_az_1c
  tags                             = local.project_tags
  ssl_policy                       = var.ssl_policy
  certificate_arn                  = var.certificate_arn
}

module "auto-scaling" {
  source                           = "./auto-scaling"
  apci_jupiter_tg                  = module.alb.apci_jupiter_tg
  apci_jupiter_alb_sg              = module.alb.apci_jupiter_alb_sg
  vpc_id                           = module.vpc.vpc_id
  image_id                         = var.image_id
  instance_type                    = var.instance_type
  key_name                         = var.key_name
  apci_jupiter_public_subnet_az_1a = module.vpc.apci_jupiter_public_subnet_az_1a
  apci_jupiter_public_subnet_az_1c = module.vpc.apci_jupiter_public_subnet_az_1c
}

module "compute" {
  source                            = "./compute"
  key_name                          = var.key_name
  apci_jupiter_private_subnet_az_1a = module.vpc.apci_jupiter_private_subnet_az_1a
  apci_jupiter_private_subnet_az_1c = module.vpc.apci_jupiter_private_subnet_az_1c
  instance_type                     = var.instance_type
  vpc_id                            = module.vpc.vpc_id
  image_id                          = var.image_id
  apci_jupiter_public_subnet_az_1a  = module.vpc.apci_jupiter_public_subnet_az_1a
  tags                              = local.project_tags
}

module "rds" {
  source                       = "./rds"
  vpc_id                       = module.vpc.vpc_id
  db_username                  = var.db_username
  db_engine_version            = var.db_engine_version
  apci_jupiter_db_subnet_az_1a = module.vpc.apci_jupiter_db_subnet_az_1a
  apci_jupiter_db_subnet_az_1c = module.vpc.apci_jupiter_db_subnet_az_1c
  tags                         = local.project_tags
  db_instance_class            = var.db_instance_class
  apci_jupiter_bastion_sg      = module.compute.apci_jupiter_bastion_sg
  db_allocated_storage         = var.db_allocated_storage
  db_parameter_group_name      = var.db_parameter_group_name
}

module "route53" {
  source                    = "./route53"
  dns_zone_id               = var.dns_zone_id
  dns_name                  = var.db_username
  apci_jupiter_alb_dns_name = module.alb.apci_jupiter_alb_dns_name
  apci_jupiter_alb_zone_id  = module.alb.apci_jupiter_alb_zone_id

}