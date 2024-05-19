
resource "aws_vpc" "shared_services_vpc" {
  cidr_block  = cidrsubnet(var.vpc_cidr_block, 8, 0)
  enable_dns_hostnames = true
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
  count             = (var.vpc_num + 1) * 2  
  vpc_id            = count.index < 2 ? aws_vpc.shared_services_vpc.id : element(aws_vpc.spoke_vpcs.*.id, floor((count.index - 2) / 2))
  cidr_block        = cidrsubnet(count.index < 2 ? aws_vpc.shared_services_vpc.cidr_block : element(aws_vpc.spoke_vpcs.*.cidr_block, floor((count.index - 2) / 2)), 8, (count.index % 2))
  availability_zone = element(var.availability_zones, (count.index % length(var.availability_zones)))
  tags = {
    Name = count.index < 2 ? format("shared_services_subnet_%02d", (count.index % 2) + 1) : format("spoke_subnet_%02d_%d", floor((count.index - 2) / 2) + 1, (count.index % 2) + 1)
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
   count             = (var.vpc_num + 1)
  transit_gateway_id    = var.tgw_id
  vpc_id                = count.index == 0 ? aws_vpc.shared_services_vpc.id : element(aws_vpc.spoke_vpcs.*.id, (count.index - 1))
  subnet_ids            = [element(aws_subnet.private_subnet.*.id, count.index * 2)]
}


# Make dyanmic - two resources for both hub and spokes
resource "aws_route_table" "spoke_rt" {
  count = var.vpc_num 
  vpc_id = aws_vpc.spoke_vpcs[count.index].id

  route {
    cidr_block = aws_vpc.shared_services_vpc.cidr_block 
    transit_gateway_id = var.tgw_id
  }
}

# Associate routing tables with subnets
resource "aws_route_table_association" "associate_spoke_rt" {
  count = var.vpc_num - 1
  subnet_id      =  aws_subnet.private_subnet[(count.index + 1) * 2].id 
  route_table_id = aws_route_table.spoke_rt[count.index].id
}

resource "aws_route_table" "service_rt" {
  vpc_id = aws_vpc.shared_services_vpc.id

  dynamic "route" {
    for_each = aws_vpc.spoke_vpcs

    content {
      cidr_block = route.value.cidr_block
      transit_gateway_id = var.tgw_id
    }
  }
}

# Associate routing tables with subnets
resource "aws_route_table_association" "associate_service_rt" {
  subnet_id      =  aws_subnet.private_subnet[0].id
  route_table_id = aws_route_table.service_rt.id
}