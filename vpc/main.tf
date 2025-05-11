resource "aws_vpc" "net-vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "net-public-subnet" {
  vpc_id            = aws_vpc.net-vpc.id
  count             = length(var.public_subnet_cidrs)
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)

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