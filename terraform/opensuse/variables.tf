variable "libvirt_disk_path" {
  description = "path for libvirt pool"
  default     = "/var/lib/libvirt/images"
}

variable "rocky_img_url" {
  description = "Rocky Linux 9 image"
  default     = "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"
}

variable "hostname" {
  default = "minione-suse"
}

variable "domain" {
  default = "midominio.org"
}

variable "memoryMB" {
  default = 1024*8
}

variable "cpu" {
  default = 2
}

variable "diskSize" {
  default = 80
}

variable "path_to_image" {
  description = "Ruta a la imagen descargada localmente"
  default     = "./local"
}