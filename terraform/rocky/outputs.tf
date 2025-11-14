output "ips" {
  value = libvirt_domain.domain-servermaas.network_interface[0].addresses
}

output "macs" {
  value = libvirt_domain.domain-servermaas.network_interface.*.mac
}