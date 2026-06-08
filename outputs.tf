output "vm_public_ips" {
  description = "Публичные IP всех 12 ВМ"
  value = {
    for i, fip in openstack_networking_floatingip_v2.fip :
    "nginx-vm-${i + 1}" => fip.address
  }
}

output "ssh_commands" {
  description = "SSH-команды для подключения"
  value = [
    for fip in openstack_networking_floatingip_v2.fip :
    "ssh -i путь к ssh ubuntu@${fip.address}"
  ]
}