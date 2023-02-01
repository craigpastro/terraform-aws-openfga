provider "aws" {
  region = local.region
}

resource "random_pet" "this" {}

locals {
  region = "us-west-2"
  name   = "openfga-${random_pet.this.id}"
  port   = 8080

  service_count = 1
  migrate       = true

  task_cpu    = 256
  task_memory = 512

  db_type           = "postgres"    # memory
  db_instance_class = "db.t3.micro" # db.m5.large
  db_name           = "postgres"
  db_username       = "postgres"
  db_password       = "password"
  db_conn_string    = "postgres://${local.db_username}:${local.db_password}@${aws_rds_cluster_instance.this.endpoint}/${local.db_name}"

  tags = {
    Name        = local.name
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}
