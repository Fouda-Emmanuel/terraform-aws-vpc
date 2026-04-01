# Basic VPC Example

This example demonstrates how to use the `fouda-emmanuel/vpc/aws` module to create a complete VPC infrastructure.

## Purpose

This example provides a working configuration of the VPC module. It is intended for **learning, testing, and as a reference** for how to use the module in your own infrastructure.

**Important: This is an EXAMPLE, not the actual module. For production use, reference the main module directly.**

## What This Example Creates

This example creates a VPC with the following resources:

- **1 VPC** with CIDR block `10.0.0.0/16`
- **2 Public Subnets** (us-east-1a, us-east-1b) with Internet Gateway
- **2 Private App Subnets** (us-east-1a, us-east-1b) with routes through NAT Gateways
- **2 Private Data Subnets** (us-east-1a, us-east-1b) with no internet access
- **1 Internet Gateway**
- **2 NAT Gateways** (one in each public subnet)
- **2 Elastic IPs** (for NAT Gateways)
- **Route Tables** and associations for all subnets

## Prerequisites

- Terraform >= 1.0
- AWS account with appropriate permissions
- AWS credentials configured

## Quick Start

```bash
# Clone the repository (or navigate to this example)
cd terraform-aws-vpc/examples/basic

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply -auto-approve

# When done, destroy resources
terraform destroy -auto-approve
```

## Customizing the Example

Create a `terraform.tfvars` file to override the default configuration:

```hcl
# terraform.tfvars
vpc_name = "production-vpc"
vpc_cidr = "172.16.0.0/16"

public_sub_cidrs = {
  "public-1" = { cidr = "172.16.1.0/24", az = "us-east-1a" }
  "public-2" = { cidr = "172.16.2.0/24", az = "us-east-1b" }
}

private_app_cidrs = {
  "app-1" = { cidr = "172.16.11.0/24", az = "us-east-1a" }
  "app-2" = { cidr = "172.16.12.0/24", az = "us-east-1b" }
}

private_data_cidrs = {
  "data-1" = { cidr = "172.16.21.0/24", az = "us-east-1a" }
  "data-2" = { cidr = "172.16.22.0/24", az = "us-east-1b" }
}

tags = {
  Environment = "production"
  ManagedBy   = "Terraform"
}
```

Then run:
```bash
terraform apply -var-file="terraform.tfvars"
```

## Outputs

After applying, you can view the outputs:

```bash
terraform output

vpc_id = "vpc-12345678"
public_subnet_ids = {
  "public-1" = "subnet-12345678"
  "public-2" = "subnet-12345679"
}
private_app_subnet_ids = {
  "app-1" = "subnet-12345680"
  "app-2" = "subnet-12345681"
}
private_data_subnet_ids = [
  "subnet-12345682",
  "subnet-12345683",
]
```

## Clean Up

To avoid ongoing charges, destroy all resources when not needed:

```bash
terraform destroy
```

## Cost Considerations

**This example creates real AWS resources that incur costs:**

| Resource | Approximate Cost |
|----------|-----------------|
| NAT Gateway (2) | ~$0.045/hour each (~$65/month total) |
| Elastic IPs (2) | ~$0.005/hour each (if not attached to running NAT) |
| VPC, Subnets, IGW | Free |

**To minimize costs:**
- Use only 1 Availability Zone for development
- Destroy resources when not in use: `terraform destroy`
- Consider using NAT Instances instead of NAT Gateways for non-production

## How to Use the Main Module

This example shows how to configure the module. In your own infrastructure, use:

```hcl
module "vpc" {
  source  = "fouda-emmanuel/vpc/aws"
  version = "1.0.0"

  vpc_name = "my-vpc"
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

  tags = {
    Environment = "production"
  }
}
```

## Troubleshooting

### Error: "No valid credential sources found"
```bash
aws configure
# or
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
```

### Error: "Availability zone not found"
Verify the AZ exists in your region:
```bash
aws ec2 describe-availability-zones --region us-east-1
```

### Error: "Insufficient permissions"
Ensure your IAM user has permissions for VPC, EC2, and network operations.

## More Information

- [Main Module Documentation](https://registry.terraform.io/modules/fouda-emmanuel/vpc/aws)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)


