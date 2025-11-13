variable "libvirt_disk_path" {
  description = "path for libvirt pool"
  default     = "/var/lib/libvirt/images"
}

variable "ubuntu_18_img_url" {
  description = "ubuntu 18.04 image"
  default     = "http://cloud-images.ubuntu.com/releases/bionic/release-20191008/ubuntu-18.04-server-cloudimg-amd64.img"
}

variable "hostname" {
  default = "minione"
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
