#--- GET ISO IMAGE

# Fetch the Rocky Linux image
resource "libvirt_volume" "os_image" {
  name = "${var.hostname}-os_image"
  pool = "pool"
  source = "${var.path_to_image}/Rocky-9-GenericCloud.latest.x86_64.qcow2"
  format = "qcow2"
}

resource "null_resource" "resize_volume" {
  provisioner "local-exec" {
    command = "sudo qemu-img resize ${libvirt_volume.os_image.id} ${var.diskSize}G"
  }

  depends_on = [libvirt_volume.os_image]
}

#--- CUSTOMIZE ISO IMAGE

# 1a. Retrieve our local cloud_init.cfg and update its content (= add ssh-key) using variables
data "template_file" "user_data" {
  template = file("${path.module}/config/cloud_init_simple.cfg")
  vars = {
    hostname = var.hostname
    fqdn = "${var.hostname}.${var.domain}"
    public_key = file("${path.module}/.ssh/id_ed25519.pub")
  }
}

# 1b. Save the result as init.cfg
data "template_cloudinit_config" "config" {
  gzip = false
  base64_encode = false
  part {
    filename = "init.cfg"
    content_type = "text/cloud-config"
    content = "${data.template_file.user_data.rendered}"
  }
}

# 2. Retrieve our network_config
data "template_file" "network_config" {
  template = file("${path.module}/config/network_config.cfg")
}

# 3. Add ssh-key and network config to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
  name = "${var.hostname}-commoninit.iso"
  pool = "pool"
  user_data      = data.template_cloudinit_config.config.rendered
  network_config = data.template_file.network_config.rendered
}

#--- CREATE VM

resource "libvirt_domain" "domain-servermaas" {
  name = "${var.hostname}"
  memory = var.memoryMB
  vcpu = var.cpu

  disk {
    volume_id = libvirt_volume.os_image.id
  }

  network_interface {
    network_name = "manage"
  }

  network_interface {
    network_name = "netstack"
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  # Rocky Linux benefits from having a serial console
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  cpu {
    mode = "host-passthrough"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}