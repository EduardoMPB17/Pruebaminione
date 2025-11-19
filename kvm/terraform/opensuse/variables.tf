variable "hostname" {
  description = "Nombre de la VM (ej. minione-suse)"
  default     = "minione-suse"
}

variable "domain" {
  description = "Dominio local ficticio (ej. midominio.org)"
  default     = "midominio.org"
}

variable "memoryMB" {
  description = "Memoria RAM en MB"
  default     = 1024 # 1GB
}

variable "cpu" {
  description = "Número de vCPUs"
  default     = 1
}

variable "diskSize" {
  description = "Tamaño final del disco en GB"
  default     = 10 # <-- ¡Ajustado a 10GB!
}

variable "path_to_image" {
  description = "Ruta absoluta a la imagen qcow2 de openSUSE Leap 15.6 NoCloud"
  default     = "/home/vicente/vmstore/images" 
}