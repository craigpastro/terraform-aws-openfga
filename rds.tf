resource "aws_db_subnet_group" "this" {
  count = var.db_type == "postgres" ? 1 : 0

  name       = "${local.name}-db-subnet-group"
  subnet_ids = aws_subnet.public.*.id

  tags = local.tags
}

resource "aws_security_group" "rds" {
  count = var.db_type == "postgres" ? 1 : 0

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

resource "aws_rds_cluster" "this" {
  count = var.db_type == "postgres" ? 1 : 0

  cluster_identifier = "${local.name}-rds-cluster"
  engine             = "aurora-postgresql"
  engine_mode        = "provisioned"
  engine_version     = "14.6"
  database_name      = var.db_name
  master_username    = var.db_username
  master_password    = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this[count.index].name
  vpc_security_group_ids = [aws_security_group.rds[count.index].id]
  skip_final_snapshot    = true

  serverlessv2_scaling_configuration {
    min_capacity = var.db_min_capacity
    max_capacity = var.db_max_capacity
  }

  tags = local.tags
}

resource "aws_rds_cluster_instance" "this" {
  count = var.db_type == "postgres" ? 1 : 0

  cluster_identifier = aws_rds_cluster.this[count.index].id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.this[count.index].engine
  engine_version     = aws_rds_cluster.this[count.index].engine_version
}
