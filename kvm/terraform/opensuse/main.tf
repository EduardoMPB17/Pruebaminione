terraform {
  required_providers {
    opennebula = {
      source  = "OpenNebula/opennebula"
      version = "~> 1.4"
    }
  }
}

# Imagen desde el marketplace (openSUSE 15 x86_64)
resource "opennebula_image" "opensuse15" {
  name         = "openSUSE 15 x86_64"
  description  = "openSUSE Terraform image"
  datastore_id = 1   # usar el datastore de imágenes
  persistent   = false
  lock         = "MANAGE"
  path         = "https://d24fmfybwxpuhu.cloudfront.net/opensuse15-7.0.0-0-20250528.qcow2"
  dev_prefix   = "vd"
  driver       = "qcow2"
  permissions  = "660"
}

# Plantilla de VM
resource "opennebula_template" "opensuse15" {
  name        = "openSUSE Terraform Template"
  description = "VM template for openSUSE 15 x86_64"
  cpu         = var.cpu
  vcpu        = var.cpu
  memory      = var.memoryMB
  permissions = "660"

  context = {
    NETWORK         = "YES" 
    SET_HOSTNAME    = "$NAME"
    USERNAME        = "vicente"
    PASSWORD_BASE64 = "MTIzCg==" # "123" en base64
    SSH_PUBLIC_KEY  = file("~/.ssh/id_minione.pub")
  }

  graphics {
    type   = "VNC"
    listen = "0.0.0.0"
    keymap = "es"
  }

  os {
    arch = "x86_64"
    boot = "disk0"
  }

  cpumodel {
    model = "host-passthrough"
  }

  disk {
    image_id = opennebula_image.opensuse15.id
    size     = var.diskSize * 1024 # Convertir GB a MB
    target   = "vda"
  }
}

# Crear 2 VMs
resource "opennebula_virtual_machine" "vm" {
  count       = 2
  name        = "opensusevm-${count.index}"
  template_id = opennebula_template.opensuse15.id

  context = {
    SET_HOSTNAME = "$NAME"
  }

  nic {
    network_id = 0 # usa la red creada por miniONE
    model      = "e1000"
  }
}