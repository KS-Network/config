# SG
resource "aws_security_group" "sg_db" {
  name        = format("%s-sg-db", var.name_prefix)
  vpc_id      = aws_vpc.vpc_main.id

  tags = {
    Name = format("%s-sg-db", var.name_prefix)
  }
}

## SG Rules
### Ingress
resource "aws_security_group_rule" "sg_db_rule_ing_conn" {
  type              = "ingress"
  from_port         = var.DB_PORT
  to_port           = var.DB_PORT
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_db.id

  lifecycle {
    create_before_destroy = true
  }
}

### Egress
resource "aws_security_group_rule" "sg_db_rule_eg_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_db.id

  lifecycle {
    create_before_destroy = true
  }
}

# Subnet group
resource "aws_db_subnet_group" "subnet_group_db" {
  name = format("%s-subnet-group-db", var.name_prefix)
  subnet_ids = [
    aws_subnet.pub_subnet_2_0.id,
    aws_subnet.pub_subnet_4_0.id
  ]

  tags = {
    Name = format("%s-subnet-group-db", var.name_prefix)
  }
}

# RDS instance
resource "aws_db_instance" "db_main" {
  allocated_storage      = 20
  max_allocated_storage  = 50
  availability_zone      = "ap-northeast-2a"
  db_subnet_group_name   = aws_db_subnet_group.subnet_group_db.name
  engine                 = "postgres"
  engine_version         = "14.5"
  instance_class         = "db.t3.micro"
  skip_final_snapshot    = true
  identifier             = format("%s-db-main", var.name_prefix)
  username               = var.DB_USERNAME
  password               = var.DB_PASSWORD
  db_name                = var.DB_NAME
  port                   = var.DB_PORT
  vpc_security_group_ids = [aws_security_group.sg_db.id]
  publicly_accessible    = true
}
