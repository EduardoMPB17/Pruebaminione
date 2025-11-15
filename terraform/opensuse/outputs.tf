output "ips" {
  description = "La primera dirección IP de la primera interfaz de red (manage)."
  
  # Esto toma la primera IP [0] de la primera interfaz de red [0]
  # Esta es la IP que Libvirt obtiene del Guest Agent
  # try() intenta obtener la IP. Si falla (por Invalid index), 
  # devuelve un string vacío "" en lugar de un error.
  value = try(libvirt_domain.domain-servermaas.network_interface[0].addresses[0], "")
}

output "macs" {
  description = "Las direcciones MAC de las interfaces de red."
  value = [
    libvirt_domain.domain-servermaas.network_interface[0].mac,
    libvirt_domain.domain-servermaas.network_interface[1].mac,
  ]
}