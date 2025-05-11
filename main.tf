module "vpc" {
  source = "./vpc"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
}

module "ec2" {
  source = "./ec2"
  subnet_ids = module.vpc.subnet_ids
  ami = "ami-053a0835435bf4f45"          # Add this line
  instance_type = "t3.medium"            # Add this line
  vpc_id = module.vpc.vpc_id             # This is also likely required
}