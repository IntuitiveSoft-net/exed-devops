variable "instance_count" {
    type = string
}
variable "image_id" {
    type = string
}
variable "flavor_id" {
    type = string
}
variable "user_name" {
    type = string
}
variable "tenant_name" {
    type = string
}
variable "password" {
    type = string
}
variable "auth_url" {
    type = string
}
variable "region" {
    type = string
}
variable "availability_zone" {
    type = string
}
variable "security_groups" {
    type = list
}
variable "lan_name" {
    type = string
}
variable "wan_name" {
    type = string
}
variable "tenant_id" {
    type = string
}
variable "user_domain_name" {
    type = string
}
variable "project_domain_id" {
    type = string
}
variable "ssh_config_file_path" {
  type = string
}
