resource "aws_db_subnet_group" "this" {
  name       = "${local.name}-db-subnet-group"
  subnet_ids = aws_subnet.public.*.id

  tags = local.tags
}

resource "aws_security_group" "rds" {
  name   = "${local.name}-rds-sg"
  vpc_id = aws_vpc.this.id

  ingress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  egress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = [aws_vpc.this.cidr_block]
  }

  tags = local.tags
}

resource "aws_db_instance" "this" {
  engine         = "postgres"
  engine_version = "14.5"
  instance_class = local.db_instance_class
  db_name        = local.db_name
  username       = local.db_username
  password       = local.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = true

  storage_type      = "gp2"
  allocated_storage = 20

  tags = local.tags
}
