terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "tfstate-996028738591-ap-south-1"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      Project     = "devops-eks-project"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

locals {
  name         = "devops-dev"
  cluster_name = "devops-dev-eks"
}

module "network" {
  source       = "../../modules/network"
  name         = local.name
  cluster_name = local.cluster_name
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

module "ecr" {
  source = "../../modules/ecr"
  name   = "devops-eks-app"
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}
