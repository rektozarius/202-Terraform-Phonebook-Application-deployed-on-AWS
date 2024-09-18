# Create application load balancer, listener and target group with health checks
#

resource "aws_lb" "phonebook-alb" {
  name               = "${var.name-prefix}-phonebook-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sec-grp.id]
  subnets            = data.aws_subnets.selected.ids
  internal           = false
}

resource "aws_lb_listener" "phonebook-alb-lstn" {
  load_balancer_arn = aws_lb.phonebook-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.phonebook-alb-trgt.arn
  }
}

resource "aws_lb_target_group" "phonebook-alb-trgt" {
  name     = "${var.name-prefix}-phonebook-alb-trgt"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 3
  }
}

# Create autoscaling group with launch template
#

resource "aws_autoscaling_group" "phonebook-asg" {
  name                      = "${var.name-prefix}-phonebook-asg"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  vpc_zone_identifier       = data.aws_subnets.selected.ids
  target_group_arns         = [aws_lb_target_group.phonebook-alb-trgt.arn]

  launch_template {
    id      = aws_launch_template.phonebook-template.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "phonebook-template" {
  name                   = "${var.name-prefix}-phonebook-tmp"
  image_id               = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.ec2-type
  key_name               = var.key-name
  vpc_security_group_ids = [aws_security_group.asg-sec-grp.id]

  user_data  = base64encode(templatefile("userdata.sh", { db-endpoint = aws_db_instance.phonebook-db.address, git-repo = var.github-repo, 
  db-name = var.db-name, db-user = var.db-user, db-pass = data.aws_ssm_parameter.db-pass.value, db-port = var.db-port }))

  # Non-secure way of passing db-password
  # user_data  = base64encode(templatefile("userdata.sh", { db-endpoint = aws_db_instance.phonebook-db.address, git-repo = var.github-repo, 
  # db-name = var.db-name, db-user = var.db-user, db-pass = var.db-pass, db-port = var.db-port }))

  depends_on = [aws_db_instance.phonebook-db]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name-prefix}-phonebook-app"
    }
  }
}

# Create rds mysql database
#

resource "aws_db_instance" "phonebook-db" {
  allocated_storage           = 20
  identifier                  = "${var.name-prefix}-phonebook-db"
  vpc_security_group_ids      = [aws_security_group.rds-sec-grp.id]
  db_name                     = var.db-name
  engine                      = "mysql"
  engine_version              = "8.0.35"
  instance_class              = var.rds-type
  username                    = var.db-user
  password                    = data.aws_ssm_parameter.db-pass.value
  port                        = var.db-port
  skip_final_snapshot         = true
  multi_az                    = false
  publicly_accessible         = false
  monitoring_interval         = 0
  backup_retention_period     = 0
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true

}