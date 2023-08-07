provider "aws" {
  region = "us-east-2"
}

# Get the VPC instance (it must exist)
data "aws_vpc" "this" {
  id = var.vpc_id
}

# Get the IGW instance attached to the VPC (it must exist)
data "aws_internet_gateway" "this" {
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}

# Retrieve ami.id for UBUNTU 20.04
data "aws_ami" "this" {
  owners = ["REDACTED"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20211129"]
  }

}

#Create random id for name or tag unicity
resource "random_id" "this" {
  byte_length = 4
}

#Create a UserKeyPair for EC2 instance
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "this" {
  content       = tls_private_key.this.private_key_pem
  filename      = "${var.ec2_name}-key.pem"
  file_permission = 0600
}

resource "aws_key_pair" "this" {
  key_name   = "${var.ec2_name}-key"
  public_key = tls_private_key.this.public_key_openssh
}

#Create a security group to be attached to the EC2 instance (enable ssh)
resource "aws_security_group" "this" {
name = "enable-ssh-${random_id.this.hex}"
vpc_id = var.vpc_id
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 22
    to_port = 22
    protocol = "tcp"
  }
// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

#Create a subnet to land the EC2 instance
resource "aws_subnet" "this" {
  vpc_id     = data.aws_vpc.this.id
  cidr_block = var.subnet_cidr

  tags = {
    Name = "${var.ec2_name}-${random_id.this.hex}"
  }
}

#Create a route table to associate to the subnet
resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.ec2_name}-${random_id.this.hex}"
  }
}

#Create the subnet/route table association
resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}

#Create the EC2 instance
resource "aws_instance" "this" {
  ami   = data.aws_ami.this.id
  subnet_id = aws_subnet.this.id
  instance_type = var.instance_type
  associate_public_ip_address = true
  source_dest_check = false
  key_name      = aws_key_pair.this.key_name
  tags = {
    Name = "${var.ec2_name}-${random_id.this.hex}"
  }
  vpc_security_group_ids = [aws_security_group.this.id]
}