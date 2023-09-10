provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "devops" {
  id = var.vpc_id
}