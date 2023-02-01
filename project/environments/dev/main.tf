terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
  }
  backend "s3" {
    bucket ="terraform-project-rozas3"
    key = "terraform.tfstate"
    region     = "us-east-1"
  }
}
provider "aws" {
  region     = "us-east-1"

}


module "vpc-dev" {
    source = "../../modules/networking"
      env = "dev"
    vpc_cidr = var.vpc_cidr_block
    public_subnet_cidrs = slice(var.public_subnet_cidr_blocks, 0, 2)
}
module "autosclaing" {
    source = "../../modules/autoscaling"
    env = "dev"
    subnets =   module.vpc-dev.subnet_id
    vpc = module.vpc-dev.vpc_id
}

module "vpc-prod" {
    source = "../../modules/networking"
    env = "prod"
}
module "autoscaling" {
    source = "../../modules/autoscaling"
    env = "prod"
    subnets =   module.vpc-prod.subnet_id
    vpc = module.vpc-prod.vpc_id
}