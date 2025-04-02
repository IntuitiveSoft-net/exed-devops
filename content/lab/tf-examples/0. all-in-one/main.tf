provider "aws" {
  region = "us-east-1"
}

# Get the VPC instance (it must exist)
data "aws_vpc" "my-vpc" {
  id = var.vpc_id
}

# Get the IGW instance attached to the VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = data.aws_vpc.my-vpc.id
  
}

#Create random id for name or tag unicity
resource "random_id" "UUID" {
  byte_length = 4
}

#Create a UserKeyPair for EC2 instance
resource "tls_private_key" "local" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "local-key" {
  content       = tls_private_key.local.private_key_pem
  filename      = "${var.ec2_name}-key.pem"
  file_permission = 0400
}

resource "aws_key_pair" "aws-key" {
  key_name   = "${var.ec2_name}-key"
  public_key = tls_private_key.local.public_key_openssh
}

#Create a security group to be attached to the EC2 instance (enable ssh)
resource "aws_security_group" "ssh" {
name = "enable-ssh-${random_id.UUID.hex}"
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
resource "aws_subnet" "public-subnet" {
  vpc_id     = data.aws_vpc.my-vpc.id
  cidr_block = var.subnet_cidr

  tags = {
    Name = "${var.ec2_name}-${random_id.UUID.hex}"
  }
}

#Create a route table to associate to the subnet
resource "aws_route_table" "public-route-table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.ec2_name}-${random_id.UUID.hex}"
  }
}

#Create the subnet/route table association
resource "aws_route_table_association" "public-subnet-association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-route-table.id
}

#Create the EC2 instance
resource "aws_instance" "vms" {
  count = var.instance_count
  ami   = "ami-084568db4383264d4"
  subnet_id = aws_subnet.public-subnet.id
  instance_type = var.instance_type
  associate_public_ip_address = true
  source_dest_check = false
  key_name      = aws_key_pair.aws-key.key_name
  tags = {
    Name = "${var.ec2_name}-${random_id.UUID.hex}-${count.index}"
  }
  vpc_security_group_ids = [aws_security_group.ssh.id]
}

#output the instance id and public ip as a dictionary
output "instance_details" {
  value = {
    for idx, instance in aws_instance.vms : idx => {
      id         = instance.id
      public_ip  = instance.public_ip
    }
  }
}

