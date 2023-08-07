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

#Read public subnet resource 
data "aws_subnet" "this" {
  filter {
    name   = "tag:Name"
    values = var.public_subnet_name
  }
}

#Create internet gateway
resource "aws_internet_gateway" "this" {
  vpc_id = data.aws_vpc.this.id

  tags = {
    Name = var.igw_name
  }
}

#Create a custome route table with default route
resource "aws_route_table" "this" {
  vpc_id = data.aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = var.public_route_table_name
  }
}

#Create the subnet/route table association
resource "aws_route_table_association" "this" {
  subnet_id      = data.aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}