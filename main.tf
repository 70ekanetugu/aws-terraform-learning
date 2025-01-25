terraform {
  # terraformバージョン違いによるトラブル防止のため設定。
  # チーム開発の場合は特に設定することを推奨。
  required_version = "~>1.10"
  # プロバイダ(aws)の進化が早く環境差異が出やすいため、同じくバージョン指定を推奨。
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
