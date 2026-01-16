resource "aws_subnet" "public_subnet_1a" {
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.0.0/18"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1a-${var.env}"
  }
  vpc_id = var.vpc_id
}
