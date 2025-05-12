resource "aws_vpc" "net-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "net-public-subnet" {
  vpc_id                  = aws_vpc.net-vpc.id
  count                   = length(var.public_subnet_cidrs)
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "net-public-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "net-igw" {
  vpc_id = aws_vpc.net-vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_route_table" "net-public-rt" {
  vpc_id = aws_vpc.net-vpc.id

  route {
    cidr_block = var.allow_all
    gateway_id = aws_internet_gateway.net-igw.id
  }

  tags = {
    Name = var.route_table
  }
}

resource "aws_route_table_association" "net-public-rt-association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.net-public-subnet[*].id, count.index)
  route_table_id = aws_route_table.net-public-rt.id
}

resource "aws_network_acl" "net-acl" {
  vpc_id = aws_vpc.net-vpc.id
  subnet_ids = aws_subnet.net-public-subnet[*].id

  # Allow all inbound traffic
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  # Allow all outbound traffic
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "net-acl"
  }
}