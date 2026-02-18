/**********************************************************
cp-alb
**********************************************************/
resource "aws_security_group" "alb_cp" {
  name        = "cp-alb-${var.env}"
  description = "cp-alb-${var.env}"
  tags = {
    Name = "cp-alb-${var.env}"
  }
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "alb_cp" {
  for_each = toset(["0.0.0.0/0"])

  security_group_id = aws_security_group.alb_cp.id
  cidr_ipv4         = each.value
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "alb_cp" {
  security_group_id = aws_security_group.alb_cp.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

/**********************************************************
cp-bastion
**********************************************************/
resource "aws_security_group" "bastion" {
  description = "cp-bastion-${var.env}"
  name        = "cp-bastion-${var.env}"
  tags = {
    Name = "cp-bastion-${var.env}"
  }
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "bastion" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

/**********************************************************
cp-nat
**********************************************************/
resource "aws_security_group" "nat" {
  description = "cp-nat-${var.env}"
  name        = "cp-nat-${var.env}"
  tags = {
    Name = "cp-nat-${var.env}"
  }
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "nat" {
  for_each = toset(var.private_subnet_cidr_blocks)

  cidr_ipv4         = each.value
  ip_protocol       = "-1"
  security_group_id = aws_security_group.nat.id
}

resource "aws_vpc_security_group_egress_rule" "nat" {
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.nat.id
}

/**********************************************************
cp-slack-metrics-backend
**********************************************************/
resource "aws_security_group" "slack_metrics_backend" {
  description = "cp-slack-metrics-backend-${var.env}"
  name        = "cp-slack-metrics-backend-${var.env}"
  tags = {
    Name = "cp-slack-metrics-backend-${var.env}"
  }
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "slack_metrics_backend" {
  for_each                     = toset([aws_security_group.alb_cp.id])
  from_port                    = 8080
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.value
  security_group_id            = aws_security_group.slack_metrics_backend.id
  to_port                      = 8080
}


resource "aws_vpc_security_group_egress_rule" "slack_metrics_backend" {
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.slack_metrics_backend.id
}

/**********************************************************
cp-db-migrator
**********************************************************/
resource "aws_security_group" "db_migrator" {
  name        = "cp-db-migrator-${var.env}"
  description = "cp-db-migrator-${var.env}"
  tags = {
    Name = "cp-db-migrator-${var.env}"
  }
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "db_migrator" {
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.db_migrator.id
}

/**********************************************************
cp-db
**********************************************************/
resource "aws_security_group" "db" {
  description = "cp-db-${var.env}"
  name        = "cp-db-${var.env}"
  tags = {
    Name = "cp-db-${var.env}"
  }
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "db" {
  for_each = toset([
    aws_security_group.slack_metrics_backend.id,
    aws_security_group.bastion.id,
    aws_security_group.db_migrator.id,
    aws_security_group.slack_metrics_lambda.id,
  ])

  from_port                    = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = each.value
  security_group_id            = aws_security_group.db.id
  to_port                      = 5432
}

resource "aws_vpc_security_group_egress_rule" "db" {
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.db.id
}

/**********************************************************
cp-slack-metrics-lambda
**********************************************************/
resource "aws_security_group" "slack_metrics_lambda" {
  description = "cp-slack-metrics-lambda-${var.env}"
  name        = "cp-slack-metrics-lambda-${var.env}"
  tags = {
    Name = "cp-slack-metrics-lambda-${var.env}"
  }
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "slack_metrics_lambda" {
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.slack_metrics_lambda.id
}