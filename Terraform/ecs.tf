module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 6.0"
  data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
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
      cpu    = 256
      memory = 512

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
        }
      }

      subnet_ids = data.aws_subnets.default.ids

      security_group_rules = {
        ingress = {
          type        = "ingress"
          from_port   = 8000
          to_port     = 8000
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }

        egress = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }

      assign_public_ip = true
    }
  }

  tags = {
    Project     = "Django Portfolio"
    Environment = "production"
  }
}