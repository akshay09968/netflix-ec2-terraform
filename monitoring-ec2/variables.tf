variable "ami" {
  type        = string
  description = "Ubuntu 20.04 LTS"
}

variable "instance_type" {
  type = string
}

variable "ec2_name" {
  type    = string
  default = "Monitoring-vm"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs to launch EC2 instance in"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID from the VPC module"
}

variable "sg-name" {
  type = string
}

