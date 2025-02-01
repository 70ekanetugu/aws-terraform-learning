module "network" {
  source       = "../../modules/network"
  cidr_block   = "10.1.0.0/16"
  env          = "ec2-demo"
  subnet_count = 2
}
