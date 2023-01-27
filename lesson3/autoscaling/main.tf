terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
  }
  backend "s3" {
    bucket ="terraform-roza-s3"
    key = "terraform.tfstate"
    region     = "us-east-1"
  }
}
provider "aws" {
  region     = "us-east-1"

}

//SECURITY_GROUP
resource "aws_security_group" "r-security" {
  name        = "r-security"
   vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  dynamic "ingress" {
    for_each = ["80", "443", "8080"]
     content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
   }
   }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
  name = "roza-template"
  instance_type = "t2.micro"
   image_id = data.aws_ami.ubuntu.id

 network_interfaces {
    device_index                = 0
    associate_public_ip_address = true
    security_groups             = ["${aws_security_group.r-security.id}"]
  }
  

 
   tags = {
    Name = "roza-templete"

  }
  user_data = base64encode(file("userdata.sh.tpl"))
# user_data = base64encode("#!/bin/bash \n sudo su \n apt update -y \n apt install apache2 -y \n apt install wget -y \n apt install unzip -y \n systemctl enable apache2 \n systemctl start apache2  \n wget https://github.com/ra1mova/portfolio/archive/refs/heads/main.zip \n unzip main.zip \n A \n cd portfolio-main \n mv README.md css/ fetch.html image/ index.html js/ shop.html /var/www/html/ \nnohup python -m SimpleHTTPServer 80 &")
}


//TARGET
resource "aws_lb_target_group" "roza" {
  name     = "target-roza"
  port     = 80
  protocol = "HTTP"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
}

//AUTO_SCALING
resource "aws_autoscaling_group" "roza" {
     name     = "roza"
  min_size             = 1
  max_size             = 3
  desired_capacity     = 3
   mixed_instances_policy {
    launch_template {
      launch_template_specification {
    launch_template_id   = "${aws_launch_template.templete.id}"
    version = "${aws_launch_template.templete.latest_version}"
      }
    }
   }

   target_group_arns = [aws_lb_target_group.roza.arn]
   vpc_zone_identifier = data.terraform_remote_state.network.outputs.subnet_id
}

//LB
resource "aws_lb" "roza" {
  name               = "learn-asg-roza-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups             = ["${aws_security_group.r-security.id}"]
  subnets         = data.terraform_remote_state.network.outputs.subnet_id
  enable_http2       = false
  enable_deletion_protection = true


  
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
