output "tags" {
  value = local.tags
}

output "endpoint" {
  value = "http://${aws_lb.this.dns_name}"
}
