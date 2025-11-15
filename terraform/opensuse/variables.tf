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
  default     = 1024 * 8 # 8GB
}

variable "cpu" {
  description = "Número de vCPUs"
  default     = 2
}

variable "diskSize" {
  description = "Tamaño final del disco en GB"
  default     = 30 # <-- ¡Ajustado a 30GB!
}

variable "path_to_image" {
  description = "Ruta relativa a la imagen qcow2 (normalmente './local')"
  default     = "./local"
}