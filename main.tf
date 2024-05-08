
terraform {
   backend "s3" {
    bucket                  = "terraform-s3-state-jonathan"
    key                     = "my-terraform-project"
    region                  = "eu-north-1"
    shared_credentials_file = "~/.aws/credentials"
  }
}

provider "aws" {
    region = "eu-north-1"

}

module "tgw" {
  source   = "./modules/tgw"
}

module "vpcs" {
  source             = "./modules/vpcs"
  vpc_num            = 2  # Adjust the number of spoke VPCs as needed
  tgw_id             = module.tgw.tgw_id
}

# # Create VPCs
# resource "aws_vpc" "vpc_a" {
#   cidr_block = "10.0.0.0/16"
#   enable_dns_hostnames = true

#     tags = {
#     Name = "VPC_A"
#   }
# }

# resource "aws_vpc" "vpc_b" {
#   cidr_block = "10.1.0.0/16"
#   enable_dns_hostnames = true

#       tags = {
#     Name = "VPC_B"
#   }
# }

# resource "aws_vpc" "vpc_c" {
#   cidr_block = "10.2.0.0/16"
#     enable_dns_hostnames = true

#    tags = {
#     Name = "VPC_C"
#   }
# }

# # Create private subnets in all VPCs
# resource "aws_subnet" "subnet_a" {
#   vpc_id     = aws_vpc.vpc_a.id
#   cidr_block = "10.0.1.0/24"

#     tags = {
#     Name = "subnet_a"
#   }
# }

# resource "aws_subnet" "subnet_b" {
#   vpc_id     = aws_vpc.vpc_b.id
#   cidr_block = "10.1.1.0/24"

#     tags = {
#     Name = "subnet_b"
#   }
# }

# resource "aws_subnet" "subnet_c" {
#   vpc_id     = aws_vpc.vpc_c.id
#   cidr_block = "10.2.1.0/24"
#   tags = {
#     Name = "subnet_c"
#   }
# }

# resource "aws_subnet" "subnet_c2" {
#   vpc_id     = aws_vpc.vpc_c.id
#   cidr_block = "10.2.2.0/24"
#   tags = {
#     Name = "subnet_c2"
#   }
# }

# # Create security group for EC2 instances in VPC A and B
# resource "aws_security_group" "allow_from_vpc_c_to_a" {
#   name        = "allow_from_vpc_c_to_a"
#   description = "Allow traffic from VPC C"

#   vpc_id = aws_vpc.vpc_a.id # You can use VPC B if needed

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["10.2.0.0/16"] # Allow traffic from VPC C
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["10.2.0.0/16"] # Allow traffic to VPC C
#   }
# }

# # Create security group for EC2 instances in VPC A and B
# resource "aws_security_group" "allow_from_vpc_c_to_b" {
#   name        = "allow_from_vpc_c_to_b"
#   description = "Allow traffic from VPC C"

#   vpc_id = aws_vpc.vpc_b.id # You can use VPC B if needed

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["10.2.0.0/16"] # Allow traffic from VPC C
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["10.2.0.0/16"] # Allow traffic to VPC C
#   }
# }


# # Create an IAM role for EC2 to enable SSM access
# resource "aws_iam_role" "ssm_role" {
#   name = "ssm_role_for_ec2"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }


# # Attach the AmazonSSMManagedInstanceCore policy to the IAM role
# resource "aws_iam_policy_attachment" "ssm_policy_attachment" {
#   name       = "ssm_policy_attachment"
#   roles      = [aws_iam_role.ssm_role.name]
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_instance_profile" "ssm_profile" {
#   name = "ssm_profile"
#   role = aws_iam_role.ssm_role.name
# }


# # Create VPC endpoints for SSM and S3
# resource "aws_vpc_endpoint" "ssm_endpoint_a" {
#   vpc_id       = aws_vpc.vpc_a.id
#   service_name = "com.amazonaws.eu-north-1.ssm"
#   vpc_endpoint_type = "Interface"
#   private_dns_enabled = true
# }


# resource "aws_vpc_endpoint" "ssm_messages_endpoint_a" {
#   vpc_id       = aws_vpc.vpc_a.id
#   service_name = "com.amazonaws.eu-north-1.ssmmessages"
#   vpc_endpoint_type = "Interface"
#   private_dns_enabled = true
# }

# resource "aws_vpc_endpoint" "ec2_messages_endpoint_a" {
#   vpc_id       = aws_vpc.vpc_a.id
#   service_name = "com.amazonaws.eu-north-1.ec2messages"
#   vpc_endpoint_type = "Interface"
#   private_dns_enabled = true
# }

# # Create VPC endpoints for SSM and S3
# resource "aws_vpc_endpoint" "ssm_endpoint_b" {
#   vpc_id       = aws_vpc.vpc_b.id
#   service_name = "com.amazonaws.eu-north-1.ssm"
#   vpc_endpoint_type = "Interface"
#   private_dns_enabled = true
# }


# resource "aws_vpc_endpoint" "ssm_messages_endpoint_b" {
#   vpc_id       = aws_vpc.vpc_b.id
#   service_name = "com.amazonaws.eu-north-1.ssmmessages"
#   vpc_endpoint_type = "Interface"
#   private_dns_enabled = true
# }

# resource "aws_vpc_endpoint" "ec2_messages_endpoint_b" {
#   vpc_id       = aws_vpc.vpc_b.id
#   service_name = "com.amazonaws.eu-north-1.ec2messages"
#   vpc_endpoint_type = "Interface"
#   private_dns_enabled = true
# }


# # Create EC2 instances in VPCs A and B
# resource "aws_instance" "instance-a" {
#   ami           = "ami-01dad638e8f31ab9a"
#   instance_type = "t3.micro"
#   subnet_id     = aws_subnet.subnet_a.id
#   vpc_security_group_ids = [aws_security_group.allow_from_vpc_c_to_a.id]

#     # Enable SSM
#   iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

# }

# resource "aws_instance" "instance-b" {
#   ami           = "ami-01dad638e8f31ab9a"
#   instance_type = "t3.micro"
#   subnet_id     = aws_subnet.subnet_b.id
#   vpc_security_group_ids = [aws_security_group.allow_from_vpc_c_to_b.id]

#     # Enable SSM
#   iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
# }

# # Create security group for interface endpoints without limitations
# resource "aws_security_group" "interface_endpoints_sg" {
#   name        = "interface_endpoints_sg"
#   description = "Security group for interface endpoints without limitations"
#   vpc_id      = aws_vpc.vpc_c.id # VPC C

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1" # Allow all protocols
#     cidr_blocks = ["0.0.0.0/0"] # Allow traffic from any source
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1" # Allow all protocols
#     cidr_blocks = ["0.0.0.0/0"] # Allow traffic to any destination
#   }
# }

# # Create interface endpoints in VPC C
# resource "aws_vpc_endpoint" "s3_endpoint" {
#   vpc_id       = aws_vpc.vpc_c.id
#   service_name = "com.amazonaws.eu-north-1.s3"
#   private_dns_enabled = false
#   vpc_endpoint_type = "Interface"
#   subnet_ids = [aws_subnet.subnet_c.id]
#   security_group_ids = [aws_security_group.interface_endpoints_sg.id]
# }

# resource "aws_vpc_endpoint" "sqs_endpoint" {
#   vpc_id       = aws_vpc.vpc_c.id
#   service_name = "com.amazonaws.eu-north-1.sqs"
#  security_group_ids = [aws_security_group.interface_endpoints_sg.id]
#   subnet_ids = [aws_subnet.subnet_c.id]
#   vpc_endpoint_type = "Interface"
# }

# # Create Transit Gateway
# resource "aws_ec2_transit_gateway" "transit_gateway" {
#   description = "My Transit Gateway"
# }

# # Attach VPCs to Transit Gateway
# resource "aws_ec2_transit_gateway_vpc_attachment" "attachment_a" {
#   subnet_ids         = [aws_subnet.subnet_a.id] 
#   transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
#   vpc_id             = aws_vpc.vpc_a.id
# }

# resource "aws_ec2_transit_gateway_vpc_attachment" "attachment_b" {
#   subnet_ids         = [aws_subnet.subnet_b.id] 
#   transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
#   vpc_id             = aws_vpc.vpc_b.id
# }

# resource "aws_ec2_transit_gateway_vpc_attachment" "attachment_c" {
#   subnet_ids         = [aws_subnet.subnet_c.id] 
#   transit_gateway_id = aws_ec2_transit_gateway.transit_gateway.id
#   vpc_id             = aws_vpc.vpc_c.id
# }

# # Create routing tables for VPCs A and B
# resource "aws_route_table" "route_table_a" {
#   vpc_id = aws_vpc.vpc_a.id

#   route {
#     cidr_block = "10.2.0.0/16" # Route traffic destined for VPC C
#     gateway_id = aws_ec2_transit_gateway.transit_gateway.id
#   }
# }

# resource "aws_route_table" "route_table_b" {
#   vpc_id = aws_vpc.vpc_b.id

#   route {
#     cidr_block = "10.2.0.0/16" # Route traffic destined for VPC C
#     gateway_id = aws_ec2_transit_gateway.transit_gateway.id
#   }
# }

# # Associate routing tables with subnets
# resource "aws_route_table_association" "association_a" {
#   subnet_id      = aws_subnet.subnet_a.id
#   route_table_id = aws_route_table.route_table_a.id
# }

# resource "aws_route_table_association" "association_b" {
#   subnet_id      = aws_subnet.subnet_b.id
#   route_table_id = aws_route_table.route_table_b.id
# }

# resource "aws_route53_zone" "private" {
#   name = "s3.eu-north-1.amazonaws.com"

#  vpc {
#     vpc_id = aws_vpc.vpc_c.id 
#   }
#  vpc {
#     vpc_id = aws_vpc.vpc_a.id 
#   }
#  vpc {
#     vpc_id = aws_vpc.vpc_b.id 
#   }
# }


# locals {
#   s3_dns = aws_vpc_endpoint.s3_endpoint.dns_entry[0].dns_name
#  // s3_ip = "${join(",", local.s3_dns.addrs)}"
# }

# resource "aws_route53_record" "s3_endpoint_record" {
#   zone_id = aws_route53_zone.private.zone_id
#   name    = ""
#   type    = "A"

#   alias {
#     name                   = aws_vpc_endpoint.s3_endpoint.dns_entry[0].dns_name
#     zone_id                = aws_vpc_endpoint.s3_endpoint.dns_entry[0].hosted_zone_id # This is the hosted zone ID for S3's endpoint in your region
#     evaluate_target_health = false
#   }
# }