locals {
  env_vars = jsondecode(
    data.aws_secretsmanager_secret_version.env.secret_string
  )
}
