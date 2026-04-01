provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "fouda-emmanuel/vpc/aws"  # Example call registry 
  version = "<version>" 

  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr

  public_sub_cidrs = var.public_sub_cidrs
  private_app_cidrs = var.private_app_cidrs
  private_data_cidrs = var.private_data_cidrs

  tags = var.tags
}