output "spoke_vpcs" {
  value = aws_vpc.spoke_vpcs
}

output "shared_services_endpoints_vpc_id" {
  value = aws_vpc.shared_services_vpc.id
}

output "shared_services_endpoints_subnet_id" {
  value = aws_subnet.private_subnet[1].id
}

