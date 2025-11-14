# MiniOne con Rocky Linux

Este directorio contiene la implementación de MiniOne sobre Rocky Linux 9, manteniendo la misma funcionalidad que la versión Ubuntu pero adaptada específicamente para Rocky Linux.

## Diferencias principales con Ubuntu

### 1. Gestor de paquetes
- **Ubuntu**: apt/apt-get
- **Rocky Linux**: dnf (heredero de yum)

### 2. Repositorios adicionales
- Rocky Linux requiere EPEL (Extra Packages for Enterprise Linux) para algunos paquetes

### 3. Configuración del sistema
- **Grupos de usuarios**: Rocky usa `wheel` en lugar de `admin`
- **Locales**: Configuración específica con `localectl`
- **Firewall**: firewalld en lugar de ufw

### 4. Servicios del sistema
- Uso de systemctl para la gestión de servicios (igual que Ubuntu moderno)

## Estructura específica para Rocky

```
terraform/rocky/
├── main.tf              # Configuración principal de la VM
├── variables.tf         # Variables específicas para Rocky
├── provider.tf          # Configuración del proveedor libvirt
├── networks.tf          # Definición de redes (igual que Ubuntu)
├── terraform.tf         # Requisitos de Terraform
├── outputs.tf           # Salidas de Terraform
├── config/
│   ├── cloud_init.cfg   # Cloud-init adaptado para Rocky
│   └── network_config.cfg # Configuración de red
├── .ssh/                # Claves SSH
└── local/               # Imagen de Rocky Linux
    └── Rocky-9-GenericCloud.latest.x86_64.qcow2
```

## Pasos para implementar

### 1. Preparar Terraform
```bash
cd terraform/rocky
terraform init
terraform plan
terraform apply
```

### 2. Obtener IP de la VM
```bash
terraform output ips
```

### 3. Actualizar inventario de Ansible
Editar `ansible/inventory_rocky.yml` con la IP obtenida.

### 4. Ejecutar instalación con Ansible
```bash
cd ../../ansible
ansible-playbook -i inventory_rocky.yml install_minione_rocky.yml
```

## Características específicas de la configuración

### Cloud-init para Rocky Linux
- Instalación automática de EPEL repository
- Configuración de locales en español
- Instalación de herramientas de desarrollo
- Habilitación del firewall con firewalld
- Configuración específica del grupo `wheel`

### Playbook Ansible para Rocky
- Verificación e instalación de EPEL si es necesario
- Actualización completa del sistema con dnf
- Instalación de dependencias específicas para Rocky
- Timeout extendido para la instalación (30 minutos)
- Verificación de servicios post-instalación

## Comandos útiles para gestión

### Ver estado de servicios OpenNebula
```bash
sudo systemctl status opennebula
sudo systemctl status opennebula-sunstone
```

### Gestión del firewall
```bash
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-port=9869/tcp
sudo firewall-cmd --reload
```

### Verificar instalación de EPEL
```bash
sudo dnf repolist | grep epel
```

## Troubleshooting específico para Rocky Linux

### Problema: No se puede instalar paquetes Python
```bash
sudo dnf install python3-pip
```

### Problema: Firewall bloquea conexiones
```bash
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=9869/tcp
sudo firewall-cmd --reload
```

### Problema: Locales no configurados
```bash
sudo localectl list-locales | grep es
sudo localectl set-locale LANG=es_ES.UTF-8
```