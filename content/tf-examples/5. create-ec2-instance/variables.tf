variable "region" {
  type = string
}
variable "access_key" {
  type = string
}
variable "secret_key" {
  type = string
}
variable "ec2_name" {
  type = string
}
variable "public_subnet_name" {
  type = string
}
variable "security_group_name" {
  type = string
}
variable "instance_type" {
  type = string
  default = "t2.nano"
}
variable "ssh_config_file_path" {
  type = string
}

