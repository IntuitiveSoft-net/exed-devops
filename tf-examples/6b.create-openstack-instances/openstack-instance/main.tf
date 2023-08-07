terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.47.0"
    }
  }
}
# Create a keypair
resource "openstack_compute_keypair_v2" "keypair" {
  name       = "${var.pod_id}-cgw-keypair"
}

# Write private_key on file
resource "local_file" "private_key" {
  content         = openstack_compute_keypair_v2.keypair.private_key
  filename        = "${var.ssh_config_file_path}/${var.pod_id}-cgw-private-key.pem"
  file_permission = 0600
}

# Create a server
resource "openstack_compute_instance_v2" "instance" {
  name            = "${var.pod_id}-cgw"
  image_id        = var.image_id
  flavor_id       = var.flavor_id
  key_pair        = "${var.pod_id}-cgw-keypair"
  availability_zone = var.availability_zone
  security_groups = var.security_groups

   network {
    name = var.wan_name
   }

   network {
    name = var.lan_name
  }
}

resource "local_file" "ssh-config" {
    content = templatefile("local-ssh-config.tmpl",
    {
      host = openstack_compute_instance_v2.instance.name,
      user = "ubuntu",
      #hostname = openstack_compute_instance_v2.instance.network[var.wan_name].fixed_ip_v4
      hostname = openstack_compute_instance_v2.instance.network[0].fixed_ip_v4
      pod_id = var.pod_id
    }
  )
  filename = "${var.pod_id}-openstack.cfg"
}

output "pod-details" {
  value = {
    host = openstack_compute_instance_v2.instance.name,
    #public = openstack_compute_instance_v2.instance.network[var.wan_name].fixed_ip_v4
    public = openstack_compute_instance_v2.instance.network[0].fixed_ip_v4
  }
}
