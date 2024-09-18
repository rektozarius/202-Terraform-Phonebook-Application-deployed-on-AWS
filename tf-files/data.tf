# Retrieve default vpc, default subnets, latest amazon linux 2023 ami and ssm database password
#

data "aws_vpc" "selected" {
  default = true
}

data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

data "aws_ssm_parameter" "db-pass" {
  name = "/202/rds/password"
}