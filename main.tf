provider "aws" {
  region = local.region
}

resource "random_pet" "this" {}

locals {
  region = var.region

  name = "openfga-${random_pet.this.id}"
  port = var.port

  service_count = var.service_count
  migrate       = var.migrate

  openfga_container_image = var.openfga_container_image

  task_cpu    = var.task_cpu
  task_memory = var.task_memory

  db_type        = var.db_type
  db_name        = var.db_name
  db_username    = var.db_username
  db_password    = var.db_password
  db_conn_string = "postgres://${local.db_username}:${local.db_password}@${aws_rds_cluster_instance.this[0].endpoint}/${local.db_name}"

  db_min_capacity = 0.5
  db_max_capacity = 1.0

  tags = merge({ Name = local.name }, var.additional_tags)
}
