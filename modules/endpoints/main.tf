resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "vpc_endpoint_sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.shared_services_vpc_id

  ingress {
    description = "HTTPS from network"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.vpc_cidr_block
  }

  tags = {
    Name = "vpc_endpoint_sg"
  }
}

resource "aws_vpc_endpoint" "endpoint" {
  count = length(var.endpoints_to_add)
  vpc_id       = var.shared_services_vpc_id
  service_name = var.endpoints_to_add[count.index].path
  //vpc_endpoint_type = var.endpoints_to_add[count.index].name != "s3" ? "Interface" : "Gateway"
   subnet_ids        = [var.shared_services_subnet_id]
  vpc_endpoint_type = "Interface"
  private_dns_enabled = false

  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]

  tags = {
    Name = var.endpoints_to_add[count.index].name
  }
}

resource "aws_route53_zone" "endpoint_zones" {
  count =  length(var.endpoints_to_add)
  name = var.endpoints_to_add[count.index].dns

  dynamic "vpc" {
     for_each = var.spoke_vpcs

    content {
      vpc_id = vpc.value.id
    }
  }
}


resource "aws_route53_record" "endpoint_records" {
  count = length(var.endpoints_to_add)
  zone_id = aws_route53_zone.endpoint_zones[count.index].zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.endpoint[count.index].dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.endpoint[count.index].dns_entry[0].hosted_zone_id # This is the hosted zone ID for S3's endpoint in your region
    evaluate_target_health = true
  }
}