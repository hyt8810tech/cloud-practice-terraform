terraform {
  backend "s3" {
    bucket       = "cp-terraform-hayato-prd"
    key          = "main.tfstate"
    region       = "ap-northeast-1"
  }
}

