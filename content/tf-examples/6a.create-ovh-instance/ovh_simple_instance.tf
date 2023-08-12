# Creating an SSH key pair resource
resource "openstack_compute_keypair_v2" "test_keypair" {
  provider   = openstack.ovh # Provider name declared in provider.tf
  name       = "openstack-cloud-key-pub" # Name of the SSH key to use for creation
  public_key = file("~/.ssh/cloud.key.pub") # Path to your SSH public key, need to generate one if doesn't exist
}

# Creating the instance
resource "openstack_compute_instance_v2" "test_terraform_instance" {
  name        = "terraform_instance" # Instance name
  provider    = openstack.ovh  # Provider name
  # image_name  = "Debian 10" # Image name Ubuntu 22.04
  image_name  = "Ubuntu 22.04"
  flavor_name = "s1-2" # Instance type name
  # Name of openstack_compute_keypair_v2 resource named keypair_test
  key_pair    = openstack_compute_keypair_v2.test_keypair.name
  network {
    name      = "Ext-Net" # Adds the network component to reach your instance
  }
}