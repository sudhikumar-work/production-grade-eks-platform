output "irsa_role_arn" {
  description = "ARN of the IRSA IAM role"
  value       = aws_iam_role.irsa_role.arn
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "oidc_provider_url" {
  value = module.eks.oidc_provider
}
