module "network" {
  source   = "../../modules/network"
  name     = "tickerops-dev"
  vpc_cidr = "10.0.0.0/16"
}
