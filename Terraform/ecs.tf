data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"
}

data "aws_iam_role" "ecs_service_linked" {
  name = "AWSServiceRoleForECS"
}

resource "aws_security_group" "ecs" {
  name        = "django-portfolio-ecs"
  description = "Allow public HTTP access to the Django ECS service"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Django application"
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 6.0"

  cluster_name = "django-portfolio-cluster"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "DEFAULT"
    }
  }

  default_capacity_provider_strategy = {
    FARGATE = {
      weight = 1
      base   = 1
    }
    FARGATE_SPOT = {
      weight = 0
    }
  }

  services = {
    django-portfolio = {
      cpu                       = 256
      memory                    = 512
      create_task_exec_iam_role = false
      task_exec_iam_role_arn    = data.aws_iam_role.ecs_task_execution.arn
      create_task_exec_policy   = false
      create_tasks_iam_role     = false
      enable_autoscaling        = false

      desired_count = 1

      container_definitions = {
        django-portfolio = {
          cpu       = 256
          memory    = 512
          essential = true

          image = "${aws_ecr_repository.portfolio.repository_url}:latest"

          port_mappings = [
            {
              name           = "django"
              container_port = 8000
              host_port      = 8000
              protocol       = "tcp"
            }
          ]

          readonly_root_filesystem = false

          environment = [
            {
              name  = "DJANGO_DEBUG"
              value = "False"
            },
            {
              name  = "DJANGO_ALLOWED_HOSTS"
              value = "*"
            },
            {
              name  = "DB_NAME"
              value = var.db_name
            },
            {
              name  = "DB_USER"
              value = var.db_username
            },
            {
              name  = "DB_PASSWORD"
              value = var.db_password
            },
            {
              name  = "DB_HOST"
              value = aws_db_instance.portfolio.address
            },
            {
              name  = "DB_PORT"
              value = "5432"
            }
          ]

          enable_cloudwatch_logging = true
          log_configuration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = "/aws/ecs/django-portfolio"
              awslogs-region        = var.aws_region
              awslogs-stream-prefix = "django"
            }
          }

          create_cloudwatch_log_group = true
          cloudwatch_log_group_name   = "/aws/ecs/django-portfolio"
        }
      }

      subnet_ids         = data.aws_subnets.default.ids
      security_group_ids = [aws_security_group.ecs.id]

      assign_public_ip = true
    }
  }
  tags = {
    Project     = "Django Portfolio"
    Environment = "production"
  }
}

