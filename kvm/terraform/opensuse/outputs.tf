output "ips" {
  description = "La primera dirección IP de la primera interfaz de red (manage)."
  
  # try() intenta obtener la IP. Si falla (por Invalid index), 
  # devuelve un string vacío "" en lugar de un error.
  value = try(libvirt_domain.domain-servermaas.network_interface[0].addresses[0], "")
}

output "macs" {
  description = "Las direcciones MAC de las interfaces de red."
  value = [
    try(libvirt_domain.domain-servermaas.network_interface[0].mac, ""),
    try(libvirt_domain.domain-servermaas.network_interface[1].mac, ""),
  ]
}