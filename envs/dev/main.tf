module "network" {
  source               = "../../modules/network"
  name                 = "tickerops-dev"
  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["ca-central-1a", "ca-central-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
}

module "alb" {
  source            = "../../modules/alb"
  name              = "tickerops-dev"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}