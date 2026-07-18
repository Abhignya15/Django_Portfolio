resource "aws_db_subnet_group" "portfolio" {
  name       = "django-portfolio-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name    = "django-portfolio-db-subnet-group"
    Project = "Django Portfolio"
  }
}

resource "aws_security_group" "rds" {
  name        = "django-portfolio-rds"
  description = "Allow PostgreSQL access from the ECS Django service"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "PostgreSQL from ECS"
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "django-portfolio-rds"
    Project = "Django Portfolio"
  }
}

resource "aws_db_instance" "portfolio" {
  identifier = "django-portfolio-db"

  engine         = "postgres"
  engine_version = "16"

  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 20
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.portfolio.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  multi_az            = false
  skip_final_snapshot = true
  deletion_protection = false

  backup_retention_period = 1

  tags = {
    Name        = "django-portfolio-db"
    Project     = "Django Portfolio"
    Environment = "production"
  }
}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "django-portfolio/db-password"
  description             = "PostgreSQL password for the Django portfolio"
  recovery_window_in_days = 0

  tags = {
    Project = "Django Portfolio"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}