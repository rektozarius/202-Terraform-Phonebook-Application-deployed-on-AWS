# Create security groups for application load balancer, rds mysql database and autoscaling group
#

resource "aws_security_group" "alb-sec-grp" {
  name   = "${var.name-prefix}-phonebook-alb-sec-grp"
  vpc_id = data.aws_vpc.selected.id
}

resource "aws_vpc_security_group_ingress_rule" "alb-igw-ref" {
  security_group_id = aws_security_group.alb-sec-grp.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "alb-egress" {
  security_group_id = aws_security_group.alb-sec-grp.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_security_group" "rds-sec-grp" {
  name   = "${var.name-prefix}-phonebook-rds-sec-grp"
  vpc_id = data.aws_vpc.selected.id
}

resource "aws_vpc_security_group_ingress_rule" "rds-asg-ref" {
  security_group_id = aws_security_group.rds-sec-grp.id

  referenced_security_group_id = aws_security_group.asg-sec-grp.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_egress_rule" "rds-egress" {
  security_group_id = aws_security_group.rds-sec-grp.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_security_group" "asg-sec-grp" {
  name   = "${var.name-prefix}-phonebook-asg-sec-grp"
  vpc_id = data.aws_vpc.selected.id
}

resource "aws_vpc_security_group_ingress_rule" "asg-alb-ref" {
  security_group_id = aws_security_group.asg-sec-grp.id

  referenced_security_group_id = aws_security_group.alb-sec-grp.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_ingress_rule" "asg-ssh-ref" {
  security_group_id = aws_security_group.asg-sec-grp.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "asg-egress" {
  security_group_id = aws_security_group.asg-sec-grp.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}
