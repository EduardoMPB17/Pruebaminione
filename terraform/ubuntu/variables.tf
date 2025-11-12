
variable "hostname" {
  default = "minione"
  description = "Nombre del servidor Canonical MaaS"
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
  default = "/home/amellado/vmstore/images"
}

