resource "openstack_compute_flavor_v2" "nginx_flavor" {
  name  = "nginx-1vcpu-512mb"
  vcpus = 2
  ram   = 4096
  disk  = 10
}

resource "openstack_compute_keypair_v2" "keypair" {
  name       = "nginx-keypair"
  public_key = file(var.ssh_public_key_path)
}

resource "openstack_networking_network_v2" "network" {
  name           = "nginx-network"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "subnet" {
  name            = "nginx-subnet"
  network_id      = openstack_networking_network_v2.network.id
  cidr            = "192.168.100.0/24"
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

data "openstack_networking_network_v2" "external" {
  external = true
}

resource "openstack_networking_router_v2" "router" {
  name                = "nginx-router"
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "router_iface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

locals {
  ubuntu_image_id = "a9e291f5-42ab-4fbc-9be5-cca7c35b0ccc"
  vm_count        = 5
}

resource "openstack_networking_secgroup_v2" "nginx_sg" {
  name        = "nginx-secgroup"
  description = "Allow SSH, HTTP and HTTPS"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.nginx_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.nginx_sg.id
}

resource "openstack_networking_secgroup_rule_v2" "https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.nginx_sg.id
}

resource "openstack_networking_port_v2" "port" {
  count              = local.vm_count
  name               = "nginx-port-${count.index + 1}"
  network_id         = openstack_networking_network_v2.network.id
  security_group_ids = [openstack_networking_secgroup_v2.nginx_sg.id]
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }
}

resource "openstack_compute_instance_v2" "nginx_vm" {
  count             = local.vm_count
  name              = "nginx-vm-${count.index + 1}"
  image_id          = local.ubuntu_image_id
  flavor_id         = openstack_compute_flavor_v2.nginx_flavor.id
  key_pair          = openstack_compute_keypair_v2.keypair.name
  availability_zone = "ru-6a"

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx
  EOF

  network {
    port = openstack_networking_port_v2.port[count.index].id
  }

  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "openstack_networking_floatingip_v2" "fip" {
  count = local.vm_count
  pool  = "external-network"
}

resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
  count       = local.vm_count
  port_id     = openstack_networking_port_v2.port[count.index].id
  floating_ip = openstack_networking_floatingip_v2.fip[count.index].address
}