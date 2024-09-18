terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Enter your preferred password as a String value
variable "db-user-pass" {
  default = ""
}

resource "aws_ssm_parameter" "db-user-pass" {
  name        = "/202/rds/password"
  description = "User password for phonebook_db"
  type        = "SecureString"
  value       = var.db-user-pass
}