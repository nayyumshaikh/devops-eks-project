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

module "eks" {
  source                   = "../../modules/eks"
  cluster_name             = local.cluster_name
  control_plane_subnet_ids = concat(module.network.private_subnet_ids, module.network.public_subnet_ids)
  node_subnet_ids          = module.network.private_subnet_ids
  node_instance_types      = ["t3.small"]
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

module "github_oidc" {
  source             = "../../modules/github-oidc"
  name               = local.name
  github_repo        = "nayyumshaikh@137756485/devops-eks-project@1415876054"
  ecr_repository_arn = module.ecr.repository_arn
  cluster_name       = local.cluster_name
}

output "github_ci_role_arn" {
  value = module.github_oidc.role_arn
}

resource "aws_eks_access_entry" "github_deploy" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.github_oidc.deploy_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_deploy" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.github_oidc.deploy_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["devops-app"]
  }

  depends_on = [aws_eks_access_entry.github_deploy]
}

output "github_deploy_role_arn" {
  value = module.github_oidc.deploy_role_arn
}

module "monitoring" {
  source       = "../../modules/monitoring"
  name         = local.name
  cluster_name = local.cluster_name
  alert_email  = var.alert_email
}

output "dashboard_name" {
  value = module.monitoring.dashboard_name
}
