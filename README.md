# terraform-aws-openfga

> For benchmarking, not production.

This is a terraform module to deploy OpenFGA in ECS with either the Postgres backend or the in-memory backend. We are using it for benchmarking purposes for the moment.

This module with create a VPC with three public subnets. It will deploy OpenFGA in the public subnets behind a load balancer. You can specify the number of instances you would like. If backed by Postgres, it will also create a serverless Postgres cluster in the public subnet.

See [variables.tf](./variables.tf) for the list of input variables.

The outputs of this module are `name` and the `endpoint` of the load balancer to reach OpenFGA.

## Notes

Keep a watch on https://github.com/hashicorp/terraform-provider-aws/issues/1703, and update the migrate portion if they ever do add an `aws_ecs_runtask`.
