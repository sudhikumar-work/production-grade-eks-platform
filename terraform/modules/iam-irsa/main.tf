# IAM Policy for Workload

resource "aws_iam_policy" "workload_policy" {
  name        = "${var.role_name}-policy"
  description = "IAM policy for IRSA role ${var.role_name}"
  policy      = var.policy_json
}

# Assume Role Policy (OIDC Trust)

data "aws_iam_policy_document" "irsa_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values = [
        "system:serviceaccount:${var.namespace}:${var.service_account}"
      ]
    }
  }
}

# IAM Role for Kubernetes Service Account

resource "aws_iam_role" "irsa_role" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role_policy.json

  tags = {
    ManagedBy = "terraform"
    Component = "irsa"
  }
}

# Attach IAM Policy to Role

resource "aws_iam_role_policy_attachment" "workload_policy_attachment" {
  role       = aws_iam_role.irsa_role.name
  policy_arn = aws_iam_policy.workload_policy.arn
}
