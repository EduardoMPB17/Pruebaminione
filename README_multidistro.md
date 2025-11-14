# Proyecto MiniOne - Multi-Distribución

Este proyecto implementa OpenNebula MiniOne sobre diferentes distribuciones Linux usando Terraform y Ansible, manteniendo cada implementación completamente separada.

## Estructura del Proyecto

```
Pruebaminione/
├── terraform/
│   ├── ubuntu/          # Implementación para Ubuntu
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── config/
│   │   ├── .ssh/
│   │   └── local/       # jammy-server-cloudimg-amd64.img
│   └── rocky/           # Implementación para Rocky Linux
│       ├── main.tf
│       ├── variables.tf
│       ├── config/
│       ├── .ssh/
│       └── local/       # Rocky-9-GenericCloud.latest.x86_64.qcow2
├── ansible/
│   ├── install_minione.yml        # Para Ubuntu
│   ├── install_minione_rocky.yml  # Para Rocky Linux
│   ├── inventory.yml              # Inventario Ubuntu
│   └── inventory_rocky.yml        # Inventario Rocky Linux
├── keys/
└── vms/
```

## Distribuciones Soportadas

### 1. Ubuntu (Original)
- **Ubicación**: `terraform/ubuntu/`
- **Imagen**: Ubuntu 22.04 LTS (Jammy)
- **Gestor de paquetes**: apt
- **Características**: Implementación base probada

### 2. Rocky Linux (Nueva)
- **Ubicación**: `terraform/rocky/`
- **Imagen**: Rocky Linux 9
- **Gestor de paquetes**: dnf
- **Características**: Compatible RHEL, incluye EPEL

## Despliegue Rápido

### Para Ubuntu:
```bash
cd terraform/ubuntu
./deploy.sh  # Si existe, o seguir pasos manuales
```

### Para Rocky Linux:
```bash
cd terraform/rocky
./deploy.sh
```

## Pasos Manuales

### 1. Ubuntu
```bash
# Preparar Terraform
cd terraform/ubuntu
terraform init
terraform apply

# Obtener IP y configurar Ansible
terraform output ips
# Editar ansible/inventory.yml con la IP

# Ejecutar Ansible
cd ../../ansible
ansible-playbook -i inventory.yml install_minione.yml
```

### 2. Rocky Linux
```bash
# Preparar Terraform
cd terraform/rocky
terraform init
terraform apply

# Obtener IP y configurar Ansible
terraform output ips
# Editar ansible/inventory_rocky.yml con la IP

# Ejecutar Ansible
cd ../../ansible
ansible-playbook -i inventory_rocky.yml install_minione_rocky.yml
```

## Diferencias Principales entre Distribuciones

| Aspecto | Ubuntu | Rocky Linux |
|---------|--------|-------------|
| **Gestor de paquetes** | apt | dnf |
| **Repositorios extra** | universe, multiverse | EPEL |
| **Grupo sudo** | admin | wheel |
| **Firewall** | ufw | firewalld |
| **Configuración locale** | locale-gen | localectl |
| **Init system** | systemd | systemd |

## Configuraciones Específicas

### Ubuntu
- Usuario por defecto: eduardo (grupo admin)
- Configuración de locales con locale-gen
- Instalación de language-pack-es
- Configuración de teclado en español

### Rocky Linux
- Usuario por defecto: eduardo (grupo wheel)
- Configuración de locales con localectl
- Instalación de glibc-langpack-es
- Instalación automática de EPEL
- Configuración de firewalld
- Instalación de Development Tools

## Gestión de Recursos

### Limpiar Ubuntu:
```bash
cd terraform/ubuntu
terraform destroy
```

### Limpiar Rocky Linux:
```bash
cd terraform/rocky
./limpia.sh
```

## Características Comunes

- **Memoria**: 8GB
- **CPU**: 2 vCores
- **Disco**: 80GB
- **Redes**: manage (172.16.25.0/24) y netstack (172.16.100.0/24)
- **SSH**: Claves ED25519
- **Cloud-init**: Configuración automática
- **Qemu Guest Agent**: Habilitado en ambas

## Acceso a Sunstone

Ambas implementaciones exponen Sunstone en el puerto 9869:
- **Ubuntu**: http://IP_UBUNTU:9869
- **Rocky**: http://IP_ROCKY:9869

Usuario: oneadmin
Contraseña: Disponible en `/var/lib/one/.one/one_auth` en cada VM

## Troubleshooting

### Problemas de conectividad SSH
```bash
# Verificar claves
ssh -i .ssh/id_ed25519 eduardo@IP_VM

# Regenerar claves si es necesario
ssh-keygen -t ed25519 -f .ssh/id_ed25519 -N ""
```

### Problemas de red
```bash
# Ubuntu
sudo ufw status
sudo ufw allow 9869

# Rocky Linux
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-port=9869/tcp
sudo firewall-cmd --reload
```

### Verificar servicios OpenNebula
```bash
sudo systemctl status opennebula
sudo systemctl status opennebula-sunstone
```

## Contribuciones

Para añadir soporte para nuevas distribuciones:

1. Crear directorio `terraform/nueva_distro/`
2. Adaptar archivos de Terraform
3. Crear cloud-init específico
4. Desarrollar playbook Ansible adaptado
5. Documentar diferencias específicas