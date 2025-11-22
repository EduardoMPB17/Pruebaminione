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
  description = "Tamaño final del disco en GB"
  default     = 30 # <-- ¡Ajustado a 30GB!
}

variable "path_to_image" {
  description = "Ruta absoluta a la imagen qcow2"
  default     = "/home/vicente/vmstore/images"
}
