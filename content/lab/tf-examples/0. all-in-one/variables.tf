variable "ec2_name" {
  type = string
  default = "my-instance"
}
variable "subnet_cidr" {
  type = string
  default = "192.168.10.0/24"
}
variable "vpc_id" {
  type = string
  default = "vpc-REDACTED"
}
variable "instance_type" {
  type = string
  default = "t2.nano"
}

variable "instance_count" {
  type = number
  default = 1
}

