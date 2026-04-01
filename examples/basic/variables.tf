
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "example-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_sub_cidrs" {
  description = "Public subnets configuration"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    "public-1" = { cidr = "10.0.1.0/24", az = "us-east-1a" }
    "public-2" = { cidr = "10.0.2.0/24", az = "us-east-1b" }
  }
}

variable "private_app_cidrs" {
  description = "Private app subnets configuration"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    "app-1" = { cidr = "10.0.11.0/24", az = "us-east-1a" }
    "app-2" = { cidr = "10.0.12.0/24", az = "us-east-1b" }
  }
}

variable "private_data_cidrs" {
  description = "Private data subnets configuration"
  type = map(object({
    cidr = string
    az   = string
  }))
  default = {
    "data-1" = { cidr = "10.0.21.0/24", az = "us-east-1a" }
    "data-2" = { cidr = "10.0.22.0/24", az = "us-east-1b" }
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "example"
    ManagedBy   = "Terraform"
  }
}