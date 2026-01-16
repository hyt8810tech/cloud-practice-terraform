resource "aws_internet_gateway" "cloud_pratica" {
  tags = {
    Name = "cp-igw-${var.env}"
  }
  vpc_id = var.vpc_id
}
