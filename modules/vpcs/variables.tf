variable "vpc_num" {
  description = "Number of spoke VPCs to create"
  type        = number
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPCs"
  type        = string
  default     = "10.0.0.0/8" # Default CIDR block, adjust as needed
}

variable "availability_zones" {
  description = "List of availability zones to distribute subnets"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"] # Default availability zones, adjust as needed
}

variable "tgw_id" {
  description = "ID of the Transit Gateway for connecting VPCs"
  type        = string
}