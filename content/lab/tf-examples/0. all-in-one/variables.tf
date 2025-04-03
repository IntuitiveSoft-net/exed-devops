variable "ec2_name" {
  type = string
  default = "my-instance"
}
variable "subnet_cidr" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "instance_type" {
  type = string
  default = "t2.nano"
}

variable "instance_count" {
  type = number
  default = 1
}

