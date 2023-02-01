

//```````````````````````````````````   (｡◕‿◕｡) VPC (｡◕‿◕｡)    ```````````````````````````````````
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-vpc-roza"
  }
}

data "aws_availability_zones" "available" {   
}

//````````````````````````````````````        ♥️‿♥️  ░S░U░B░N░E░T░ ♥️‿♥️       `````````````````````````````````` 
resource "aws_subnet" "public_subnets" {
  count = "${length(var.public_subnet_cidrs)}"
  vpc_id     = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
   tags = {
    Name = "${var.env}-public-${count.index + 1}"
  }
}

//       (ᵔᴥᵔ)         (ᵔᴥᵔ)        (ᵔᴥᵔ)     INTERNET_GATEWAY     (ᵔᴥᵔ)           (ᵔᴥᵔ)         (ᵔᴥᵔ)       (ᵔᴥᵔ)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.env}-igw"
  }
}


//✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿         ROUTE_TABLE           ✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿✿
resource "aws_route_table" "route" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.env}-rtb"
  }
}

//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\route_table_association\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
resource "aws_route_table_association" "a" {
 count = length(var.public_subnet_cidrs)
  # subnet_id      = aws_subnet.subnet[count.index].id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.route[*].id, count.index)
}
