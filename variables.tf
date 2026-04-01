variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "my-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_sub_cidrs" {
  description = "Public Subnet CIDR Block with AZ. Example: { \"public-sub-1\" = { cidr = \"10.0.1.0/24\", az = \"us-east-1a\" } }"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    "public-sub-1" = { cidr = "10.0.1.0/24", az = "PLACEHOLDER-AZ-1" }
    "public-sub-2" = { cidr = "10.0.2.0/24", az = "PLACEHOLDER-AZ-2" }
    "public-sub-3" = { cidr = "10.0.3.0/24", az = "PLACEHOLDER-AZ-3" }
  }
}

variable "private_app_cidrs" {
  description = "Private App Subnet CIDR Block with AZ. Example: { \"private-app-sub-1\" = { cidr = \"10.0.11.0/24\", az = \"us-east-1a\" } }"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    "private-app-sub-1" = { cidr = "10.0.11.0/24", az = "PLACEHOLDER-AZ-1" }
    "private-app-sub-2" = { cidr = "10.0.12.0/24", az = "PLACEHOLDER-AZ-2" }
    "private-app-sub-3" = { cidr = "10.0.13.0/24", az = "PLACEHOLDER-AZ-3" }
  }
}

variable "private_data_cidrs" {
  description = "Private Data Subnet CIDR Block with AZ. Example: { \"private-data-sub-1\" = { cidr = \"10.0.21.0/24\", az = \"us-east-1a\" } }"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    "private-data-sub-1" = { cidr = "10.0.21.0/24", az = "PLACEHOLDER-AZ-1" }
    "private-data-sub-2" = { cidr = "10.0.22.0/24", az = "PLACEHOLDER-AZ-2" }
    "private-data-sub-3" = { cidr = "10.0.23.0/24", az = "PLACEHOLDER-AZ-3" }
  }
}

variable "igw_name" {
  description = "Internet Gateway Name"
  type        = string
  default     = "my-igw"
}

variable "tags" {
  description = "Optional tags to apply to all resources"
  type        = map(string)
  default     = {}
}