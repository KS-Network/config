# VPC
resource "aws_vpc" "vpc_main" {
  cidr_block = "172.16.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = format("%s-vpc-main", var.name_prefix)
  }
}

# Endpoint
## IGW
resource "aws_internet_gateway" "igw_main" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = format("%s-igw", var.name_prefix)
  }
}

# Public Subnet
## Route Table
resource "aws_route_table" "pub_rtb" {
  vpc_id = aws_vpc.vpc_main.id

  tags = {
    Name = format("%s-public-rtb", var.name_prefix)
  }
}

resource "aws_route" "pub_rtb_default" {
  route_table_id         = aws_route_table.pub_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_main.id
}

## Subnet - 172.16.1.0
resource "aws_subnet" "pub_subnet_1_0" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = "172.16.1.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = format("%s-public-subnet-1-0", var.name_prefix)
  }
}

resource "aws_route_table_association" "pub_subnet_1_0_rtb_assoc" {
  subnet_id      = aws_subnet.pub_subnet_1_0.id
  route_table_id = aws_route_table.pub_rtb.id
}

## Subnet - 172.16.2.0 - DB Active
resource "aws_subnet" "pub_subnet_2_0" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = "172.16.2.0/24"

  availability_zone = "ap-northeast-2a"

  tags = {
    Name = format("%s-public-subnet-2-0", var.name_prefix)
  }
}

resource "aws_route_table_association" "pub_subnet_2_0_rtb_assoc" {
  subnet_id      = aws_subnet.pub_subnet_2_0.id
  route_table_id = aws_route_table.pub_rtb.id
}

## Subnet - 172.16.4.0 - DB Standby
resource "aws_subnet" "pub_subnet_4_0" {
  vpc_id     = aws_vpc.vpc_main.id
  cidr_block = "172.16.4.0/24"

  availability_zone = "ap-northeast-2c"

  tags = {
    Name = format("%s-private-subnet-3-0", var.name_prefix)
  }
}

resource "aws_route_table_association" "pub_subnet_3_0_rtb_assoc" {
  subnet_id      = aws_subnet.pub_subnet_4_0.id
  route_table_id = aws_route_table.pub_rtb.id
}
