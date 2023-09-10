#Configure aws provider
provider "aws" {
  region = "us-east-1"
  access_key = "REDACTED"
  secret_key = "REDACTED"
}

#Create a subnet
resource "aws_subnet" "this" {
  vpc_id     = "vpc-REDACTED"
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "podx-public-subnet"
  }
}