locals {
  public_subnet_cidrs  = [for i in range(length(var.azs)) : cidrsubnet(var.cidr, 8, i)]
  private_subnet_cidrs = [for i in range(length(var.azs)) : cidrsubnet(var.cidr, 8, i + 10)]
  db_subnet_cidrs      = [for i in range(length(var.azs)) : cidrsubnet(var.cidr, 8, i + 20)]
}
