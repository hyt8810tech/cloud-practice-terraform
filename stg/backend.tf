terraform {
  backend "s3" {
    bucket       = "cp-terraform-hayato-stg"
    key          = "main.tfstate"
    region       = "ap-northeast-1"
  }
}

