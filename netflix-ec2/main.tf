locals {
  ingress_ports = ["22", "80", "443", "8080", "9000"]
}

resource "aws_security_group" "net-sg" {
  name   = var.sg-name
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "net-sg-ingress" {
  for_each          = toset(local.ingress_ports)
  security_group_id = aws_security_group.net-sg.id
  from_port         = each.value
  to_port           = each.value
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "net-sg-egress" {
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.net-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
}

resource "aws_instance" "net-ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.net-sg.id]

  tags = {
    Name = var.ec2_name
  }
}