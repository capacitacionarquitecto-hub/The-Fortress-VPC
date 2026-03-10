# ============================================================================
# Compute Layer - Elastic Scalability
# ============================================================================

# Dynamic Data Source to find the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Launch Template for Auto Scaling Group
resource "aws_launch_template" "web_app" {
  name_prefix   = "${var.PROJECT_NAME}-tpl-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from the Fortress Cloud</h1><p>Instance: $(hostname -f)</p>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.PROJECT_NAME}-web-server" }
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.PROJECT_NAME}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_01.id, aws_subnet.public_subnet_02.id]

  tags = { Name = "${var.PROJECT_NAME}-alb" }
}

# Target Group for ASG
resource "aws_lb_target_group" "web_tg" {
  name     = "${var.PROJECT_NAME}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

# ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port             = 80
  protocol         = "HTTP"

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.web_tg.arn
    }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.web_tg.arn]
  vpc_zone_identifier = [aws_subnet.private_subnet_01.id, aws_subnet.private_subnet_02.id]

  launch_template {
    id      = aws_launch_template.web_app.id
    version = "$Latest"
  }
}