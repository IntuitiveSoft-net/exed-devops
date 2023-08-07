# Configure aws provider
provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create a UserKeyPair for EC2 instance
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key on local file
resource "local_file" "this" {
  content       = tls_private_key.this.private_key_pem
  filename      = "${var.ssh_config_file_path}/${var.ec2_name}-private-key.pem"
  file_permission = 0600
}

# Save the public key on AWS
resource "aws_key_pair" "this" {
  key_name   = "${var.ec2_name}-key"
  public_key = tls_private_key.this.public_key_openssh
}