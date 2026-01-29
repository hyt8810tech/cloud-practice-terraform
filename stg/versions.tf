terraform {
  required_version = "~> 1.14.1" // 1.14.1 以上 1.15.0 未満 を許容

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0" // s3 public module使用のため6.28.0~に修正
    }
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "cp-terraform-stg"

  default_tags {
    tags = {
      Env = "stg"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "cp-terraform-stg"
  alias   = "us_east_1"

  default_tags {
    tags = {
      Env = "stg"
    }
  }
}

