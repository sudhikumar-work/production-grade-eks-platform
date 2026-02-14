module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.name
  cluster_version = "1.29"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  enable_irsa = true

  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  eks_managed_node_groups = {
    default = {
      instance_types = [var.instance_type]

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      capacity_type = "ON_DEMAND"

      labels = {
        role = "general"
      }

      tags = {
        Name = "${var.name}-node-group"
      }
    }
  }

  tags = {
    Environment = var.name
    ManagedBy   = "terraform"
  }
}
