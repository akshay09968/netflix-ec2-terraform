output "vpc_id" {
  value = aws_vpc.net-vpc.id
}

output "vpc_name" {
  value = aws_vpc.net-vpc.tags["Name"]
}

output "internet_gw_id" {
  value = aws_internet_gateway.net-igw.id
}

output "route_table_id" {
  value = aws_route_table.net-public-rt.id
}

output "subnet_ids" {
  value = aws_subnet.net-public-subnet.*.id
}