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

  db_name        = "postgres"
  db_username    = "postgres"
  db_password    = "password"
  db_conn_string = "postgres://${local.db_username}:${local.db_password}@${aws_rds_cluster_instance.this.endpoint}/${local.db_name}"

  db_min_capacity = 0.5
  db_max_capacity = 1.0

  tags = {
    Name        = local.name
    ManagedBy   = "Terraform"
    Environment = "dev"
  }
}
