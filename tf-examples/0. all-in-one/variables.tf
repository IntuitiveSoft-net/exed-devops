variable "ec2_name" {
  type = string
  default = "tf-gin208-vm"
}
variable "subnet_cidr" {
  type = string
  default = "10.0.254.0/24"
}
variable "vpc_id" {
  type = string
  default = "vpc-REDACTED"
}
variable "instance_type" {
  type = string
  default = "t2.nano"
}

