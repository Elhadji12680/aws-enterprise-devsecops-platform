provider "aws" {
  region = "us-east-1"
}

# Apply EKS first before ArgoCD: terraform apply -target=module.eks -var-file=dev.tfvars
# Then apply the full stack:       terraform apply -var-file=dev.tfvars
provider "kubernetes" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.eks_cluster_ca_certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_name]
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Requires Terraform >= 1.10 — use_lockfile replaces DynamoDB for state locking
  backend "s3" {
    bucket       = "jupiter-terraform-state-171239862305"
    key          = "jupiter/statefile"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

module "vpc" {
  source            = "./vpc"
  vpc_cidr_block    = var.vpc_cidr_block
  subnet_cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  tags              = local.project_tags
}

module "ec2" {
  source                    = "./ec2"
  vpc_id                    = module.vpc.vpc_id
  public_subnet_az_1a_id    = module.vpc.public_subnet_az_1a_id
  ami                       = var.ami
  instance_type             = var.instance_type
  key_name                  = var.key_name
  tags                      = local.project_tags
  ec2_instance_profile_name = module.iam.ec2_instance_profile_name
}

module "alb" {
  source                 = "./alb"
  vpc_id                 = module.vpc.vpc_id
  tags                   = local.project_tags
  public_subnet_az_1a_id = module.vpc.public_subnet_az_1a_id
  public_subnet_az_1b_id = module.vpc.public_subnet_az_1b_id
  ssl_policy             = var.ssl_policy
  certificate_arn        = var.certificate_arn
}

module "route53" {
  source          = "./route53"
  name            = var.name
  route53_zone_id = var.route53_zone_id
  alb_dns_name    = module.alb.alb_dns_name
  alb_zone_id     = module.alb.alb_zone_id
}

module "rds" {
  source                   = "./rds"
  rds_secrets_manager_role = module.iam.rds_secrets_manager_role
  engine                   = var.engine
  engine_version           = var.engine_version
  vpc_id                   = module.vpc.vpc_id
  db_name                  = var.db_name
  db_subnet_az_1a          = module.vpc.db_subnet_az_1a
  db_subnet_az_1b          = module.vpc.db_subnet_az_1b
  instance_class           = var.instance_class
  allocated_storage        = var.allocated_storage
  parameter_group_name     = var.parameter_group_name
  tags                     = local.project_tags
}

module "iam" {
  source     = "./iam"
  account_id = var.account_id
  region     = var.region
}

module "eks" {
  source                  = "./eks"
  vpc_id                  = module.vpc.vpc_id
  private_subnet_az_1a_id = module.vpc.private_subnet_az_1a_id
  private_subnet_az_1b_id = module.vpc.private_subnet_az_1b_id
  tags                    = local.project_tags
  kubernetes_version      = var.kubernetes_version
  node_instance_type      = var.node_instance_type
  node_desired_size       = var.node_desired_size
  node_min_size           = var.node_min_size
  node_max_size           = var.node_max_size
}

module "argocd" {
  source                 = "./argocd"
  argocd_chart_version   = var.argocd_chart_version
  argocd_git_repo_url    = var.argocd_git_repo_url
  argocd_git_repo_branch = var.argocd_git_repo_branch
}

module "trivy" {
  source              = "./trivy"
  trivy_chart_version = var.trivy_chart_version
}

module "sonarqube" {
  source                  = "./sonarqube"
  sonarqube_chart_version = var.sonarqube_chart_version
}

module "monitoring" {
  source                         = "./monitoring"
  prometheus_stack_chart_version = var.prometheus_stack_chart_version
  grafana_admin_password         = var.grafana_admin_password
}
