
#--- GET ISO IMAGE

# Fetch the ubuntu image
resource "libvirt_volume" "os_image" {
  name = "${var.hostname}-os_image"
  pool = "pool"
  source = "${var.path_to_image}/jammy-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "null_resource" "fix_permissions" {
  provisioner "local-exec" {
    command = "sudo chown vicente:libvirt ${libvirt_volume.os_image.id} && sudo chmod 664 ${libvirt_volume.os_image.id}"
  }
  depends_on = [libvirt_volume.os_image]
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
  template = file("${path.module}/config/cloud_init.cfg")
  vars = {
    hostname = var.hostname
    fqdn = "${var.hostname}.${var.domain}"
    public_key = file("~/.ssh/id_minione.pub")
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

  # Asegurar que el resize termine antes de crear la VM
  depends_on = [null_resource.resize_volume]


  network_interface {
    network_name = "manage"
    mac = "52:54:00:F2:CA:68"
  }

  network_interface {
    network_name = "netstack"
    mac = "52:54:00:F6:CD:D6"
  }


  cloudinit = libvirt_cloudinit_disk.commoninit.id

  # Ubuntu can hang is a isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
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
