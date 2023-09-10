# Define required providers
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.47.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name   = var.user_name
  tenant_name = var.tenant_name
  password    = var.password
  auth_url    = var.auth_url
  region      = var.region
  project_domain_id = var.project_domain_id
  tenant_id = var.tenant_id
  user_domain_name = var.user_domain_name
}

module "student-instances" {

  source = "./openstack-instance"
  count = var.instance_count

  pod_id = "pod${count.index+1}"

  flavor_id            = var.flavor_id
  image_id             = var.image_id
  lan_name             = var.lan_name
  availability_zone = var.availability_zone

  security_groups      = var.security_groups
  ssh_config_file_path = var.ssh_config_file_path
  wan_name             = var.wan_name
}

resource "local_file" "openstack-inventory" {
    content = templatefile("openstack-inventory.tmpl",
    {
      hosts = module.student-instances.*.pod-details
    }
  )
  filename = "openstack-inventory.md"
}
