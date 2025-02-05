# =============================================================================
# ネットワーク (VPC, IGW, NAT, サブネット, ルートテーブル)
#
module "network" {
  source       = "./modules/network"
  cidr_block   = "10.0.0.0/16"
  env          = "demo"
  subnet_count = 2
}
