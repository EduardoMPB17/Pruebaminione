terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

# --- IMAGEN ---
resource "libvirt_volume" "os_image" {
  name   = "${var.hostname}-os_image_v3"  # <--- CAMBIO A v3
  pool   = "default"                       # <--- CAMBIO A 'default' (más seguro)
  # source sigue apuntando a tu archivo local, eso está bien
  source = "${var.path_to_image}/openSUSE-Leap-15.6.x86_64-NoCloud.qcow2"
  format = "qcow2"
}

resource "null_resource" "resize_volume" {
  provisioner "local-exec" {
    # OJO: Ahora la ruta es en /var/lib/libvirt/images/
    command = "sudo qemu-img resize /var/lib/libvirt/images/${libvirt_volume.os_image.name} ${var.diskSize}G"
  }
  depends_on = [libvirt_volume.os_image]
}

# --- CLOUD-INIT ---
data "template_file" "user_data" {
  template = file("${path.module}/config/cloud_init_simple.cfg")
  vars = {
    hostname   = var.hostname
    fqdn       = "${var.hostname}.${var.domain}"
    public_key = file("${path.module}/.ssh/id_ed25519.pub")
  }
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.user_data.rendered
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "${var.hostname}-commoninit.iso"
  pool      = "default"
  user_data = data.template_cloudinit_config.config.rendered
}

# --- VM ---
resource "libvirt_domain" "domain-servermaas" {
  name       = var.hostname
  memory     = var.memoryMB
  vcpu       = var.cpu
  qemu_agent = true # IMPORTANTE: True para que reporte la IP

  disk {
    volume_id = libvirt_volume.os_image.id
  }

  # INTERFAZ 1: MANAGE (IP ESTÁTICA FIJADA POR MAC EN LIBVIRT)
  network_interface {
    network_name   = "manage"
    # Usamos la MAC que definimos en manage.xml para asegurar la IP 172.16.25.2
    mac            = "52:54:00:09:f3:3f"
    wait_for_lease = true # Terraform esperará a que tenga IP
  }

  # INTERFAZ 2: NETSTACK
  network_interface {
    network_name   = "netstack"
    # Usamos la MAC que definimos en netstack.xml para asegurar la IP 172.16.100.100
    mac            = "52:54:00:09:f3:4f"
    wait_for_lease = true
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  cpu {
    mode = "host-passthrough"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}