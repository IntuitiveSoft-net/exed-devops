variable "vpc_name" {
    type = string
}

variable "pod" {
    type = string
}

variable "region" {
    type = string
}

variable "access_key" {
    type = string
}

variable "secret_key" {
    type = string
}

variable "customer_gateway_ip" {
    type = string
}

variable "customer_gateway_asn" {
    type = string
}

variable "customer_gateway_type" {
    type = string
}

variable "vpn_connection_type" {
    type = string
}

variable "vpn_connection_destination" {
    type = string
}

variable "ansible_vars_file" {
    type = string
}

variable "rt_name" {
    type = string
}
