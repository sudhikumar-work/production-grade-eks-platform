
locals {
  env_vars = jsondecode(
    data.aws_secretsmanager_secret_version.env.secret_string
  )
}

# VPC

module "vpc" {
  source = "../../modules/vpc"

  name = "dev"
  cidr = "10.0.0.0/16"

  azs = [
    "ap-south-1a",
    "ap-south-1b",
    "ap-south-1c"
  ]
}

# EKS

module "eks" {
  source = "../../modules/eks"

  name            = "dev"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  instance_type = local.env_vars.eks_instance_type
  desired_size  = 2
  min_size      = 1
  max_size      = 4
}

# IRSA for App

module "app_irsa" {
  source = "../../modules/iam-irsa"

  role_name = "dev-app-irsa-role"

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = replace(module.eks.oidc_provider_url, "https://", "")

  namespace       = "default"
  service_account = "app-sa"

  policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "*"
      }
    ]
  })
}

# RDS

module "rds" {
  source = "../../modules/rds"

  name     = "dev-postgres"
  db_name  = "devdb"
  username = local.env_vars.db_username

  vpc_id     = module.vpc.vpc_id
  db_subnets = module.vpc.db_subnets

  allowed_security_group_id = module.eks.node_security_group_id

  instance_class = "db.t3.micro"
  multi_az       = false
}

# ECR Repository

module "ecr" {
  source = "../../modules/ecr"

  name = "dev-application-repo"
}

module "alb_controller_irsa" {
  source = "../../modules/iam-irsa"

  role_name = "dev-alb-controller-irsa"

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = replace(module.eks.oidc_provider_url, "https://", "")

  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"

  policy_json = data.aws_iam_policy_document.alb_controller_policy.json
}

resource "helm_release" "aws_load_balancer_controller" {
  name = "aws-load-balancer-controller"
  depends_on = [
    module.alb_controller_irsa
  ]
  namespace        = "kube-system"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  create_namespace = false

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.alb_controller_irsa.irsa_role_arn
  }
}
