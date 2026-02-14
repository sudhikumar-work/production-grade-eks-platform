output "repository_url" {
  value = aws_ecr_repository.application_repository.repository_url
}

output "repository_arn" {
  value = aws_ecr_repository.application_repository.arn
}
