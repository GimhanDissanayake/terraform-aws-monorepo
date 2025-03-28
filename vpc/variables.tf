################################################################################
# Common 
################################################################################
variable "project" {
  description = "Common name"
  type        = string
}

variable "environment" {
  description = "Stage where the environment is provitioning"
  type        = string
}

################################################################################
# VPC
################################################################################
variable "cidr" {
  description = "The IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_network_address_usage_metrics" {
  description = "Determines whether network address usage metrics are enabled for the VPC"
  type        = bool
  default     = null
}

variable "secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
  type        = list(string)
  default     = []
}

################################################################################
# Publiс Subnets
################################################################################
variable "public_subnets" {
  description = "Public Subnet CIDR Block"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "azs" {
  description = "Define this if you want to create subnets in specific Availability zones"
  type        = list(string)
  default     = []
}

variable "public_subnet_tags" {
  description = "Public subnet tags"
  type        = map(string)
  default     = null
}

################################################################################
# Private Subnets
################################################################################
variable "private_subnets" {
  description = "Private Subnet CIDR Block"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "private_subnet_tags" {
  description = "Private subnet tags"
  type        = map(string)
  default     = null
}

################################################################################
# NAT Gateway
################################################################################
variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateway"
  type        = bool
  default     = false
}

################################################################################
# VPC Peering
################################################################################
variable "enable_vpc_peering" {
  description = "Should be true if you want to create vpc peering connections"
  type        = bool
  default     = false
}

variable "vpc_peering_connections" {
  description = "Details of VPC with which you are creating the VPC Peering Connection"
  type        = list(map(string))
  default = [
    {
      peer_owner_id       = ""
      peer_region         = ""
      peer_vpc_id         = ""
      acceptor_cidr_block = ""
    }
  ]
}

################################################################################
# S3 Gateway Endpoint
################################################################################
variable "create_s3_gateway_endpoint" {
  description = "Should be true if you need to create S3 Gateway Enpoint"
  type        = bool
  default     = false
}