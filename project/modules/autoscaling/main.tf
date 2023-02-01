

//SECURITY_GROUP
resource "aws_security_group" "r-security" {
  name        = "${var.env}-r-security"
   vpc_id      = var.vpc

  dynamic "ingress" {
    for_each = var.allow_ports
     content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }
   }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

//LAUNCH_TEMPLATE
resource "aws_launch_template" "templete" {
  name = "${var.env}roza-template"
  instance_type = var.instance_type
  image_id = data.aws_ami.ubuntu.id

 network_interfaces {
    device_index                = 0
    associate_public_ip_address = true
    security_groups             = ["${aws_security_group.r-security.id}"]
  }
   tag_specifications {
    resource_type = "instance"

   tags = {
    Name = "${var.env}-roza-instance"
  }
  }

  user_data = base64encode(file("../../modules/autoscaling/userdata.sh.tpl"))

}


//TARGET
resource "aws_lb_target_group" "roza" {
  name     = "${var.env}-target-r"
  port     = 80
  protocol = "HTTP"
  vpc_id      = var.vpc
}

//AUTO_SCALING
resource "aws_autoscaling_group" "roza" {
     name     = "${var.env}-roza"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 3
   mixed_instances_policy {
    launch_template {
    launch_template_specification {
    launch_template_id   = "${aws_launch_template.templete.id}"
    version = "$Latest"
      }
    }
   }
   target_group_arns = [aws_lb_target_group.roza.arn]
   vpc_zone_identifier = var.subnets
}

//LB
resource "aws_lb" "roza" {
  name               = "${var.env}-roza-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups             = ["${aws_security_group.r-security.id}"]
  subnets         = var.subnets
  enable_deletion_protection = false
}

//LISTENER
resource "aws_lb_listener" "roza" {
  load_balancer_arn = aws_lb.roza.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.roza.arn
  }
}
