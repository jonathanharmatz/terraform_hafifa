variable "shared_services_vpc_id" {
    type = string
}

variable "shared_services_subnet_id" {
    type = string
}

variable "spoke_vpcs" {
    type = any
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPCs"
  type        = list(string)
  default     = ["10.0.0.0/8"] # Default CIDR block, adjust as needed
}


variable "endpoints_to_add" {
    type = list(object({
        name = string
        path = string
        dns = string
    }))
    default = [
        {name = "ssm", path= "com.amazonaws.eu-north-1.ssm", dns = "ssm.eu-north-1.amazonaws.com"},
        {name = "ssmmessages", path = "com.amazonaws.eu-north-1.ssmmessages", dns = "ssmmessages.eu-north-1.amazonaws.com"},
        {name = "ec2messages", path= "com.amazonaws.eu-north-1.ec2messages", dns = "ec2messages.eu-north-1.amazonaws.com"},
        {name = "sqs", path = "com.amazonaws.eu-north-1.sqs", dns = "sqs.eu-north-1.amazonaws.com"},
        {name = "s3", path = "com.amazonaws.eu-north-1.s3", dns = "s3.eu-north-1.amazonaws.com"}
        ]
}

