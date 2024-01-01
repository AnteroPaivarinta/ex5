resource "openstack_compute_keypair_v2" "keypair" {
  name       = "vm1"
  public_key = file("/home/owner/public.pub")
}

resource "openstack_compute_secgroup_v2" "secgroup_1" {
  name        = "secgroup_public"
  description = "Security group for VM 1"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "secgroup_2" {
  name        = "secgroup_private"
  description = "Security group for VM 2"

  rule {
    from_port   = 1
    to_port     = 65535
    ip_protocol = "tcp"
    cidr        = "192.168.1.0/24"
  }
}

resource "openstack_networking_floatingip_v2" "flip_1" {
  pool    = "my_pool"
  address = "128.214.254.0"
}

resource "openstack_compute_instance_v2" "vm1" {
  count       = 1
  name        = "vm1"
  flavor_name = "standard.small"
  image_name  = "ubuntu-20.04"
  key_pair    = "vm1"
  security_groups = [openstack_compute_secgroup_v2.secgroup_1.name]
  network {
    name = "project_2008903"
  }
}

resource "openstack_compute_floatingip_associate_v2" "flip_1_associate" {
  count       = 1
  floating_ip = openstack_networking_floatingip_v2.flip_1.address
  instance_id = openstack_compute_instance_v2.vm1[count.index].id
}

resource "openstack_compute_instance_v2" "vm2" {
  count       = 3
  name        = "vm${count.index + 1}"
  flavor_name = "standard.small"
  image_name  = "ubuntu-20.04"
  security_groups = [openstack_compute_secgroup_v2.secgroup_2.name]
  network {
    name = "project_2008903"
  }
}
