locals {
  # Dynamically map each private app subnet to a public subnet
  nat_gateway_map = {
    for idx, name in keys(var.private_app_cidrs) :
    name => element(keys(var.public_sub_cidrs), idx % length(var.public_sub_cidrs))
  }
}