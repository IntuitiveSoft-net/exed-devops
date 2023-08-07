# Configure aws provider
provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# Read vpc resource 
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = var.vpc_name
  }
}

# Create a security group which only allow ssh in ingress
# and all traffic in egress
resource "aws_security_group" "this" {
name = var.security_group_name
vpc_id = data.aws_vpc.this.id
tags = {
  Name = var.security_group_name
  }
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 22
    to_port = 22
    protocol = "tcp"
  }
# Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}