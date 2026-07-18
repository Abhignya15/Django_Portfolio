variable "aws_region" {
  description = "AWS region where the portfolio infrastructure will be created"
  type        = string
  default     = "us-east-1"
}

variable "db_name" {
  description = "Initial PostgreSQL database name"
  type        = string
  default     = "portfolio_db"
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "portfolio_admin"
}

variable "db_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}