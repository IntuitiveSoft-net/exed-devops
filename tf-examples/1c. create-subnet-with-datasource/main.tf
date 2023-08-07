#Configure aws provider
provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

#Read vpc resource 
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = var.vpc_name
  }
}

#Create a subnet
resource "aws_subnet" "this" {
  vpc_id     = data.aws_vpc.this.id
  cidr_block = var.cidr_block

  tags = {
    Name = var.subnet_name
  }
}

#Capture vpc_id in output variable
output "vpc_id" {
  value = data.aws_vpc.this.id
}

#Capture vpc_cidr_block in output variable
output "vpc_cidr_block" {
  value = data.aws_vpc.this.cidr_block
}