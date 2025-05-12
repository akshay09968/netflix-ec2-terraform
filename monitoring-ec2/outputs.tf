output "ami_id" {
  value = aws_instance.net-ec2.ami
}

output "aws_instance_id" {
  value = aws_instance.net-ec2.id
}

output "aws_security_group_id" {
  value = aws_security_group.net-sg.id
}