output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.my_vpc.id
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = { for k, v in aws_subnet.public_sub : k => v.id }
}

output "private_app_subnet_ids" {
  description = "Private App Subnet IDs"
  value       = { for k, v in aws_subnet.private_app_sub : k => v.id }
}

output "private_data_subnet_ids" {
  description = "Private Data Subnet IDs"
  value       = values(aws_subnet.private_data_sub)[*].id
}