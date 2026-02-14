data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}


data "aws_iam_policy_document" "alb_controller_policy" {

  # ELB Permissions
  statement {
    effect = "Allow"

    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*"
    ]

    resources = ["*"]
  }

  # EC2 Permissions
  statement {
    effect = "Allow"

    actions = [
      "ec2:Describe*",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupIngress"
    ]

    resources = ["*"]
  }

  # IAM Service Linked Role
  statement {
    effect = "Allow"

    actions = [
      "iam:CreateServiceLinkedRole"
    ]

    resources = ["*"]
  }

  # Optional WAF & Shield
  statement {
    effect = "Allow"

    actions = [
      "wafv2:*",
      "shield:*"
    ]

    resources = ["*"]
  }
}

# Fetch Secrets

data "aws_secretsmanager_secret" "env" {
  name = "eks/dev"
}

data "aws_secretsmanager_secret_version" "env" {
  secret_id = data.aws_secretsmanager_secret.env.id
}

data "aws_iam_policy_document" "karpenter_controller_policy" {

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateLaunchTemplate",
      "ec2:DeleteLaunchTemplate",
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeImages",
      "ec2:DescribeAvailabilityZones",
      "iam:PassRole",
      "ssm:GetParameter"
    ]

    resources = ["*"]
  }
}
