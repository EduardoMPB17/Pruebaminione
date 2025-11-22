output "vm_names" {
  description = "Nombres de las VMs creadas"
  value       = [for vm in opennebula_virtual_machine.vm : vm.name]
}

output "vm_ids" {
  description = "IDs de las VMs en OpenNebula"
  value       = [for vm in opennebula_virtual_machine.vm : vm.id]
}

output "vm_macs" {
  description = "MACs de las NICs de las VMs"
  value       = flatten([
    for vm in opennebula_virtual_machine.vm : [
      for nic in vm.nic : nic.computed_mac
    ]
  ])
}

output "vm_ips" {
  description = "IPs de las VMs"
  value       = flatten([
    for vm in opennebula_virtual_machine.vm : [
      for nic in vm.nic : nic.computed_ip
    ]
  ])
}
