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
# //VPC
# resource "aws_vpc" "vpc" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "vpc-roza"
#   }
# }
#public_subnets

resource "aws_subnet" "public_subnets" {
  count = "${length(local.subnet_names)}"
   vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  map_public_ip_on_launch = true
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
   cidr_block = local.cidr_block[count.index]
  tags = {
    Name = local.subnet_names[count.index]
  }
}
#aws_instance
resource "aws_instance" "instance" {
  for_each = toset(data.terraform_remote_state.network.outputs.subnet_id)
   ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id = each.value
  tags = {
    Name = "roza-instance"
  }

}

#target group
resource "aws_lb_target_group" "target" {
  name     = "example"
  protocol = "HTTP"
  port     = 80
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
  tags = {
    Name = "target"
  }
}

# Attachment to the target group
resource "aws_lb_target_group_attachment" "attachment" {
  for_each = aws_instance.instance 
  target_group_arn = aws_lb_target_group.target[count].arn
  port             = 80
  target_id = each.value.id
   count = var.target_group_count == 1 ? 1 : 0
}