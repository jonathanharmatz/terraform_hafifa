output "shared_services_endpoints_subnet_id" {
  value = aws_subnet.private_subnet[1].id
}