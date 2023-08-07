
variable "flavor_id" {
    type = string
}
variable "image_id" {
    type = string
}
variable "pod_id" {
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

variable "ssh_config_file_path" {
  type = string
}
