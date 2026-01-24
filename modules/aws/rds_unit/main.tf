resource "aws_db_subnet_group" "subnet_group" {
  name       = var.subnet_group_name
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = var.subnet_group_name
  }
}

resource "aws_db_parameter_group" "parameter_group" {
  name        = var.parameter_group_name
  family      = var.family
  description = "cp-db-parameter-group-${var.env}" //説明を変更するとreplaceになるためそのままにする
}

resource "aws_db_instance" "main" {
  engine                              = "postgres"
  identifier                          = var.identifier
  db_name                             = var.db_name
  engine_version                      = var.engine_version
  instance_class                      = var.instance_class
  username                            = "postgres"
  ca_cert_identifier                  = "rds-ca-rsa2048-g1"
  performance_insights_enabled        = true
  max_allocated_storage               = 1000
  allocated_storage                   = 20
  storage_encrypted                   = true
  copy_tags_to_snapshot               = true
  skip_final_snapshot                 = true
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  vpc_security_group_ids              = var.security_group_ids
  db_subnet_group_name                = aws_db_subnet_group.subnet_group.name
  parameter_group_name                = aws_db_parameter_group.parameter_group.name

}


