module "vpc" {
  source              = "./vpc"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
}

module "netflix-ec2" {
  source        = "./netflix-ec2"
  subnet_ids    = module.vpc.subnet_ids
  ami           = var.ami
  instance_type = var.instance_type
  vpc_id        = module.vpc.vpc_id
  sg-name       = var.netflix-sg-name
  ec2_name      = "netflix-ec2"
}

module "monitoring-ec2" {
  source        = "./monitoring-ec2"
  subnet_ids    = module.vpc.subnet_ids
  ami           = var.ami
  instance_type = var.instance_type
  vpc_id        = module.vpc.vpc_id
  sg-name       = var.monitoring-sg-name
  ec2_name      = "monitoring-ec2"
}