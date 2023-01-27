locals {
  name = "roza"
  names = ["us-east-2a","us-east-2b","us-east-2c" ]
  subnet_names = ["subnet1","subnet2","subnet3"]
  cidr_block   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", ]
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
  count = "${length(local.subnet_names)}"
  vpc_id     = aws_vpc.vpc.id
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  cidr_block = local.cidr_block[count.index]
  tags = {
    Name = local.subnet_names[count.index]
  }
}

//INTERNET_GATEWAY
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "roza-gw"
  }
}
provider "aws" {
    alias = "prod"
}

//ROUTE_TABLE
resource "aws_route_table" "route" {

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "rtb-${local.name}"
  }
}

//route_table_association
resource "aws_route_table_association" "a" {
  provider = aws.prod
  count          = length(local.subnet_names)
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.route.id
}

resource "aws_internet_gateway" "lunara" {
    count = terraform.workspace == "cholpon" ? 1 : 0
    tags     = {
        "Name" = "igw-aktan-krasavchik"
    }
} 