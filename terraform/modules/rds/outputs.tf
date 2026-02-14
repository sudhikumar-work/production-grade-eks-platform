output "rds_endpoint" {
  value = aws_db_instance.database_instance.endpoint
}

output "rds_identifier" {
  value = aws_db_instance.database_instance.id
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_credentials.arn
}
