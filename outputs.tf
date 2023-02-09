output "name" {
  value = local.name
}

output "endpoint" {
  value = "http://${aws_lb.this.dns_name}"
}
