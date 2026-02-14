# Security Group for RDS

resource "aws_security_group" "rds_sg" {
  name        = "${var.name}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow Postgres from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [var.allowed_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-rds-sg"
  }
}

# Subnet Group

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.db_subnets

  tags = {
    Name = "${var.name}-subnet-group"
  }
}

# Generate Secure Random Password

resource "random_password" "db_master_password" {
  length           = 20
  special          = true
  override_special = "!@#$%^&*()-_=+"
}


# RDS Instance

resource "aws_db_instance" "database_instance" {
  identifier              = var.name
  engine                  = "postgres"
  engine_version          = "15"
  instance_class          = var.instance_class
  allocated_storage       = 20
  storage_encrypted       = true
  db_name                 = var.db_name
  username                = var.username
  password                = password = random_password.db_master_password.result
  multi_az                = var.multi_az
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  backup_retention_period = 7
  deletion_protection     = true
  skip_final_snapshot     = false
  final_snapshot_identifier = local.final_snapshot_identifier

  tags = {
    Name      = var.name
    ManagedBy = "terraform"
  }
}

# Store DB Credentials in Secrets Manager

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = local.secret_name
  description = "Database credentials for ${var.name}"

  tags = {
    Name      = local.secret_name
    ManagedBy = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    username = var.username
    password = random_password.db_master_password.result
    endpoint = aws_db_instance.database_instance.endpoint
    db_name  = var.db_name
  })
}
