variable "aws_region" {
  type    = string
  default = "ap-south-2"
}

variable "instance_type" {
  type = string
}

variable "ami" {
  type = string
}

variable "netflix-sg-name" {
  type = string
}

variable "monitoring-sg-name" {
  type = string
}

