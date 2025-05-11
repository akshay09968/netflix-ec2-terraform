variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  default     = ["ap-south-2a", "ap-south-2b"]
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
  default     = "net-vpc"
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "allow_all" {
  type    = string
  default = "0.0.0.0/0"
}

variable "igw_name" {
  type    = string
  default = "net-igw"
}

variable "route_table" {
  type    = string
  default = "net-public-rt"
}