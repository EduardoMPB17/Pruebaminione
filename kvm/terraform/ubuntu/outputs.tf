output "ips" {
  description = "Direcciones IP estáticas de la VM"
  value = [
    "172.16.25.2",
    "172.16.200.2"
  ]
}

output "macs" {
  description = "Direcciones MAC de las interfaces de red"
  value = [
    libvirt_domain.domain-servermaas.network_interface[0].mac,
    libvirt_domain.domain-servermaas.network_interface[1].mac,
  ]
}