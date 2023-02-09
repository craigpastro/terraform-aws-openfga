provider "aws" {
  region = var.region
}

resource "random_pet" "this" {}

locals {
  name = "openfga-${random_pet.this.id}"

  db_conn_string = "postgres://${var.db_username}:${var.db_password}@${aws_rds_cluster_instance.this[0].endpoint}/${var.db_name}"

  tags = merge({
    Name      = local.name,
    Terraform = "true",
  }, var.additional_tags)
}
