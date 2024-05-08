resource "aws_ec2_transit_gateway" "tgw" {
  description = "Transit Gateway for connecting VPCs"
  

  tags = {
    Name = var.tgw_name
  }
}

output "tgw_id" {
  value = aws_ec2_transit_gateway.tgw.id
}
