module "vpc" {
  source              = "./vpc"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
}

module "ec2" {
  source        = "./ec2"
  subnet_ids    = module.vpc.subnet_ids
  ami           = var.ami
  instance_type = var.instance_type
  vpc_id        = module.vpc.vpc_id
}