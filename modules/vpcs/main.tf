
resource "aws_vpc" "shared_services_vpc" {
  cidr_block  = var.vpc_cidr_block
  tags = {
    Name = "shared services vpc"
  }
}

resource "aws_vpc" "spoke_vpcs" {
  count       = var.vpc_num
  cidr_block  = cidrsubnet(var.vpc_cidr_block, 8, count.index + 1)
  tags = {
    Name = format("vpc_%d", count.index + 1)
  }
}

resource "aws_subnet" "private_subnet" {
  count             = var.vpc_num * 2
  vpc_id            = count.index == 0 ? aws_vpc.shared_services_vpc.id : element(aws_vpc.spoke_vpcs.*.id, (count.index - 1) / 2)
  cidr_block        = cidrsubnet(count.index == 0 ? aws_vpc.shared_services_vpc.cidr_block : element(aws_vpc.spoke_vpcs.*.cidr_block, (count.index - 1) / 2), 8, (count.index - 1) % 2)
  availability_zone = element(var.availability_zones, (count.index - 1) % length(var.availability_zones))
  tags = {
    Name = count.index == 0 ? format("shared_services_subnet_%02d", (count.index % 2) + 1) : format("spoke_subnet_%02d_%d", ((count.index - 1) / 2) + 1, (count.index % 2) + 1)
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "shared_tgw_attachment" {
  transit_gateway_id    = var.tgw_id
  vpc_id                = aws_vpc.shared_services_vpc.id
  subnet_ids            = [element(aws_subnet.private_subnet.*.id, 0)]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_tgw_attachments" {
  count                 = var.vpc_num
  transit_gateway_id    = var.tgw_id
  vpc_id                = element(aws_vpc.spoke_vpcs.*.id, count.index)
  subnet_ids            = [element(aws_subnet.private_subnet.*.id, count.index * 2)]
}