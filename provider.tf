terraform {
  backend "s3" {
    region         = "ap-northeast-2"
    bucket         = "hk-global-tfstate-bucket"
    key            = "ks-network-tfstate"
    dynamodb_table = "hk-global-tfstate-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.17.1"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}
