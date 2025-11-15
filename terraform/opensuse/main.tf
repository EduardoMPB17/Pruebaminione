##############################################
#   PROVEEDORES
##############################################

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

##############################################
#  IMAGEN BASE openSUSE
##############################################

resource "libvirt_volume" "os_image" {
  name   = "${var.hostname}-os_image"
  pool   = "pool"
  source = "${var.path_to_image}/openSUSE-Leap-15.6.x86_64-NoCloud.qcow2"
  format = "qcow2"
}

resource "null_resource" "resize_volume" {
  provisioner "local-exec" {
    command = "sudo qemu-img resize ${libvirt_volume.os_image.id} ${var.diskSize}G"
  }

  depends_on = [libvirt_volume.os_image]
}

##############################################
#  CLOUD-INIT: SOLO user_data
##############################################

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
  pool      = "pool"
  user_data = data.template_cloudinit_config.config.rendered
}

##############################################
#  REDES
##############################################

resource "libvirt_network" "netstack_network" {
  name      = "netstack"
  mode      = "none"
  autostart = true
}

##############################################
#  CREAR LA VM
##############################################

resource "libvirt_domain" "domain-servermaas" {
  name   = var.hostname
  memory = var.memoryMB
  vcpu   = var.cpu

  disk {
    volume_id = libvirt_volume.os_image.id
  }

  # eth0 → red "manage"
  network_interface {
    network_name = "manage"
  }

  # eth1 → red "netstack"
  network_interface {
    network_name = "netstack"
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