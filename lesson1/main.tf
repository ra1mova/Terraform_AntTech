terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.51.0"
    }
  }
}
provider "aws" {
  access_key = "AKIAWDUNQQYXUWQMH7E6"
  secret_key = "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"
  region     = "us-west-2"
}
//KEY_PEIR
resource "aws_key_pair" "demo_roza" {
  key_name = "demo_roza"
  public_key = file("~/.ssh/id_rsa.pub")
}

//VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-roza"
  }
}

data "aws_availability_zones" "available" {

    
}

//SUBNET
resource "aws_subnet" "subnet" {
    count = "${length(local.names1)}"
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.${count.index}.0/24"
    availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true

  tags = {
    Name = "roza${count.index}"
  }
}
# resource "aws_subnet" "subnet" {
#   vpc_id     = aws_vpc.vpc.id
#   cidr_block = "10.0.8.0/24"

#   tags = {
#     Name = "subnet2-roza"
#   }
# }

//INTERNET_GATEWAY
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "roza-gw"
  }
}

//ROUTE_TABLE
resource "aws_route_table" "route" {
count = 3
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "roza-route${count.index}"
  }
}

//route_table_association
resource "aws_route_table_association" "a" {
count = length(local.names1)
  subnet_id      = aws_subnet.subnet.*.id[count.index]
  route_table_id = aws_route_table.route.*.id[count.index]
}

//SECURITY_GROUP
resource "aws_security_group" "r-security" {
  name        = "r-security"
  vpc_id      = aws_vpc.vpc.id

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
  image_id           = "ami-0333305f9719618c7"
  instance_type = "t2.micro"

 network_interfaces {
    device_index                = 0
    associate_public_ip_address = true
    security_groups             = ["${aws_security_group.r-security.id}"]
  }
  
  key_name      = aws_key_pair.demo_roza.key_name
 
   tags = {
    Name = "roza-templete"

  }
  user_data = base64encode(templatefile("userdata.sh.tpl"))
# user_data = base64encode("#!/bin/bash \n sudo su \n apt update -y \n apt install apache2 -y \n apt install wget -y \n apt install unzip -y \n systemctl enable apache2 \n systemctl start apache2  \n wget https://github.com/ra1mova/portfolio/archive/refs/heads/main.zip \n unzip main.zip \n A \n cd portfolio-main \n mv README.md css/ fetch.html image/ index.html js/ shop.html /var/www/html/ \nnohup python -m SimpleHTTPServer 80 &")
}


//TARGET
resource "aws_lb_target_group" "terramino" {
  name     = "target-roza"
  port     = 80
  protocol = "HTTP"
  vpc_id     = aws_vpc.vpc.id
}

//AUTO_SCALING
resource "aws_autoscaling_group" "terramino" {
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

    target_group_arns = [aws_lb_target_group.terramino.arn]
  vpc_zone_identifier  = aws_subnet.subnet[*].id
}

//LB
resource "aws_lb" "terramino" {
  name               = "learn-asg-terramino-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups             = ["${aws_security_group.r-security.id}"]
  subnets = aws_subnet.subnet.*.id
  enable_http2       = false
  enable_deletion_protection = true


  
}

//LISTENER
resource "aws_lb_listener" "terramino" {
  load_balancer_arn = aws_lb.terramino.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.terramino.arn
  }
}