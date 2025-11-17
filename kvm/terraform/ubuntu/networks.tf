resource "libvirt_network" "manage" {
  name      = "manage"
  mode      = "nat"
  domain    = "manage.local"
  addresses = ["172.16.25.0/24"]
  dhcp {
    enabled = true
  }
  dns {
    enabled = true
  }
}

resource "libvirt_network" "netstack" {
  name      = "netstack"
  mode      = "nat"
  domain    = "netstack.local"
  addresses = ["172.16.100.0/24"]
  dhcp {
    enabled = true
  }
}
