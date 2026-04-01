# AWS VPC Module

Terraform module to create a Highly Available (HA) VPC infrastructure on AWS with public, private app, and private data subnets.

## Overview

This module creates a complete VPC setup with:
- **Public subnets** - For load balancers, bastion hosts, and NAT gateways
- **Private app subnets** - For application servers (EC2, ECS, etc.) that need internet access via NAT
- **Private data subnets** - For databases (RDS, etc.) that should not have any internet access

The module automatically creates NAT gateways in public subnets and routes traffic from private app subnets through them, ensuring high availability across multiple Availability Zones.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         VPC                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           Public Subnets (with NAT Gateways)         │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │ AZ-1     │  │ AZ-2     │  │ AZ-3     │            │   │
│  │  │ Internet │  │ Internet │  │ Internet │            │   │
│  │  │ Gateway  │  │ Gateway  │  │ Gateway  │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘            │   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Private App Subnets (via NAT)                │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │ AZ-1     │  │ AZ-2     │  │ AZ-3     │            │   │
│  │  │ App Tier │  │ App Tier │  │ App Tier │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘            │   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │        Private Data Subnets (No Internet)            │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │ AZ-1     │  │ AZ-2     │  │ AZ-3     │            │   │
│  │  │ Database │  │ Database │  │ Database │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘            │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Features

- **Multi-AZ High Availability** - Distributes subnets across multiple Availability Zones
- **NAT Gateway per AZ** - Each public subnet has its own NAT gateway for redundancy
- **Automatic Routing** - Routes traffic from private app subnets through NAT gateways
- **Internet Gateway** - Public subnets have direct internet access
- **Flexible Subnet Configuration** - Works with 1, 2, 3, or more subnets per tier
- **Tag Support** - Add custom tags to all resources

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Usage

### Basic Example

```hcl
module "vpc" {
  source  = "fouda-emmanuel/vpc/aws"
  version = "1.0.0"

  vpc_name = "production-vpc"
  vpc_cidr = "10.0.0.0/16"

  public_sub_cidrs = {
    "public-1" = { cidr = "10.0.1.0/24", az = "us-east-1a" }
    "public-2" = { cidr = "10.0.2.0/24", az = "us-east-1b" }
    "public-3" = { cidr = "10.0.3.0/24", az = "us-east-1c" }
  }

  private_app_cidrs = {
    "app-1" = { cidr = "10.0.11.0/24", az = "us-east-1a" }
    "app-2" = { cidr = "10.0.12.0/24", az = "us-east-1b" }
    "app-3" = { cidr = "10.0.13.0/24", az = "us-east-1c" }
  }

  private_data_cidrs = {
    "data-1" = { cidr = "10.0.21.0/24", az = "us-east-1a" }
    "data-2" = { cidr = "10.0.22.0/24", az = "us-east-1b" }
    "data-3" = { cidr = "10.0.23.0/24", az = "us-east-1c" }
  }

  tags = {
    Environment = "production"
  }
}
```

### Minimal Example (Single AZ)

If you only need one Availability Zone:

```hcl
module "vpc" {
  source  = "fouda-emmanuel/vpc/aws"
  version = "1.0.0"

  vpc_name = "simple-vpc"
  vpc_cidr = "10.0.0.0/16"

  public_sub_cidrs = {
    "public-1" = { cidr = "10.0.1.0/24", az = "us-east-1a" }
  }

  private_app_cidrs = {
    "app-1" = { cidr = "10.0.11.0/24", az = "us-east-1a" }
  }

  private_data_cidrs = {
    "data-1" = { cidr = "10.0.21.0/24", az = "us-east-1a" }
  }
}
```

### How Routing Works

1. **Public Subnets**: Have direct internet access through the Internet Gateway
2. **Private App Subnets**: Traffic routes through NAT gateways in public subnets
   - Each private app subnet is mapped to a public subnet in the same AZ when possible
   - If you have different numbers of subnets, the module automatically distributes them
3. **Private Data Subnets**: Have no internet access (only route tables, no routes to NAT/IGW)

### NAT Gateway Mapping

The module automatically maps private app subnets to public subnets for NAT gateway access:

- With 3 public and 3 private app subnets: Each private app subnet uses NAT in its AZ
- With 2 public and 3 private app subnets: Private subnets are distributed across available NAT gateways
- Works with any number of subnets (1, 2, 3, or more)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_name | Name of the VPC | `string` | `"my-vpc"` | no |
| vpc_cidr | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| public_sub_cidrs | Public subnets with CIDR and AZ | `map(object({cidr=string, az=string}))` | See defaults | no |
| private_app_cidrs | Private app subnets with CIDR and AZ | `map(object({cidr=string, az=string}))` | See defaults | no |
| private_data_cidrs | Private data subnets with CIDR and AZ | `map(object({cidr=string, az=string}))` | See defaults | no |
| igw_name | Name of the Internet Gateway | `string` | `"my-igw"` | no |
| tags | Additional tags for all resources | `map(string)` | `{}` | no |

### Default Values

The module comes with defaults for a 3-AZ setup:

```hcl
public_sub_cidrs = {
  "public-sub-1" = { cidr = "10.0.1.0/24", az = "PLACEHOLDER-AZ-1" }
  "public-sub-2" = { cidr = "10.0.2.0/24", az = "PLACEHOLDER-AZ-2" }
  "public-sub-3" = { cidr = "10.0.3.0/24", az = "PLACEHOLDER-AZ-3" }
}

private_app_cidrs = {
  "private-app-sub-1" = { cidr = "10.0.11.0/24", az = "PLACEHOLDER-AZ-1" }
  "private-app-sub-2" = { cidr = "10.0.12.0/24", az = "PLACEHOLDER-AZ-2" }
  "private-app-sub-3" = { cidr = "10.0.13.0/24", az = "PLACEHOLDER-AZ-3" }
}

private_data_cidrs = {
  "private-data-sub-1" = { cidr = "10.0.21.0/24", az = "PLACEHOLDER-AZ-1" }
  "private-data-sub-2" = { cidr = "10.0.22.0/24", az = "PLACEHOLDER-AZ-2" }
  "private-data-sub-3" = { cidr = "10.0.23.0/24", az = "PLACEHOLDER-AZ-3" }
}
```

**Note:** Replace `PLACEHOLDER-AZ-1` with actual AZ names like `us-east-1a`, `eu-west-1b`, etc or you can replace also the `cidr`

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the created VPC |
| public_subnet_ids | Map of public subnet names to IDs |
| private_app_subnet_ids | Map of private app subnet names to IDs |
| private_data_subnet_ids | List of private data subnet IDs |

### Using Outputs

After creating the VPC, you can reference its outputs in other modules:

```hcl
module "vpc" {
  source = "fouda-emmanuel/vpc/aws"
  # ... configuration
}

# Use VPC ID for other resources
resource "aws_security_group" "app_sg" {
  vpc_id = module.vpc.vpc_id
  # ... rules
}

# Launch instances in private app subnets
resource "aws_instance" "app_server" {
  subnet_id = values(module.vpc.private_app_subnet_ids)[0]
  # ... configuration
}
```

## High Availability Explanation

This module is designed for high availability:

- **Multi-AZ Distribution**: Subnets are distributed across multiple Availability Zones
- **Redundant NAT Gateways**: Each public subnet has its own NAT gateway
- **Automatic Failover**: If one NAT gateway fails, traffic is automatically routed through another
- **Separate Database Tier**: Data subnets have no internet access for security

### Recommended Configuration

For production workloads:
- Use 3 Availability Zones for maximum availability
- Place application servers in private app subnets
- Place databases in private data subnets
- Use load balancers in public subnets

For development/staging:
- Use 1-2 Availability Zones to save costs
- Still maintains separation between app and data tiers

## Example: Complete Project Structure

When using this module, your project structure might look like:

```
my-infrastructure/
├── main.tf                 # Calls the VPC module and other resources
├── variables.tf            # Your environment variables
├── outputs.tf              # Your outputs
├── terraform.tfvars        # Your values
└── backend.tf              # State storage configuration
```

Example `main.tf`:

```hcl
provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "fouda-emmanuel/vpc/aws"
  version = "1.0.0"

  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr

  public_sub_cidrs    = var.public_sub_cidrs
  private_app_cidrs   = var.private_app_cidrs
  private_data_cidrs  = var.private_data_cidrs

  tags = var.tags
}

# Your other resources
module "rds" {
  source  = "fouda-emmanuel/rds/aws"
  version = "1.0.0"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_data_subnet_ids
  # ... other configuration
}
```

## License

MIT

---

## Need Help?

- See the [examples](./examples) directory for more usage scenarios
- Check the Terraform Registry documentation for this module
- Open an issue on GitHub for bugs or feature requests

