resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Name = var.vpc_name
    },
    var.tags
  )
}

resource "aws_subnet" "public_sub" {
  for_each = var.public_sub_cidrs
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = each.value.cidr
  availability_zone = each.value.az

  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = each.key
    },
    var.tags
  )
}

resource "aws_subnet" "private_app_sub" {
  for_each = var.private_app_cidrs
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    {
      Name = each.key
    },
    var.tags
  )
}

resource "aws_subnet" "private_data_sub" {
  for_each = var.private_data_cidrs
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    {
      Name = each.key
    },
    var.tags
  )
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = merge(
    {
      Name = var.igw_name
    },
    var.tags
  )
}

resource "aws_eip" "my_eips" {
  for_each = aws_subnet.public_sub
  domain   = "vpc"

  tags = merge(
    {
      Name = "${each.key}-eip"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "my_nats" {
  for_each = aws_subnet.public_sub
  allocation_id = aws_eip.my_eips[each.key].id
  subnet_id     = each.value.id

  tags = merge(
    {
      Name = "${each.key}-nat"
    },
    var.tags
  )
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = merge(
    {
      Name = "public-rt"
    },
    var.tags
  )
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route_table_association" "public_route_associate" {
  for_each = aws_subnet.public_sub
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_app_rt" {
  for_each = aws_subnet.private_app_sub
  vpc_id = aws_vpc.my_vpc.id

  tags = merge(
    {
      Name = "${each.key}-rt"
    },
    var.tags
  )
}

resource "aws_route" "private_app_route" {
  for_each = aws_route_table.private_app_rt
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nats[local.nat_gateway_map[each.key]].id
}

resource "aws_route_table_association" "private_app_route_associate" {
  for_each = aws_subnet.private_app_sub
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_app_rt[each.key].id
}

resource "aws_route_table" "private_data_rt" {
  for_each = aws_subnet.private_data_sub
  vpc_id = aws_vpc.my_vpc.id

  tags = merge(
    {
      Name = "${each.key}-rt"
    },
    var.tags
  )
}

resource "aws_route_table_association" "private_data_route_associate" {
  for_each = aws_subnet.private_data_sub
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_data_rt[each.key].id
}