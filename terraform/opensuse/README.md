# MiniOne sobre openSUSE Leap 15.6  
Implementación de MiniOne utilizando Terraform + Libvirt, con imágenes NoCloud y cloud-init adaptado específicamente para openSUSE.

Esta versión mantiene **la misma estructura y automatización** que las variantes para Ubuntu y Rocky, pero incluye ajustes especiales porque **openSUSE no usa Netplan**, sino `wicked` con archivos `ifcfg-*`.

---

## 🧩 Diferencias clave con Ubuntu/Rocky

### 🔌 Gestión de red
- Ubuntu/Rocky → cloud-init + Netplan  
- **openSUSE → wicked + archivos `/etc/sysconfig/network/ifcfg-*`**

Por ello, esta versión **no usa `network_config` de cloud-init**.  
Toda la red se configura vía `write_files` en `cloud_init_simple.cfg`.

### 📦 Paquetes y sistema
- openSUSE usa `zypper`.
- No requiere repos adicionales.
- El firewall por defecto es `firewalld`.
- El grupo administrativo es `wheel`.

---

## 📁 Estructura del proyecto

terraform/opensuse/
├── main.tf # Configuración principal de la VM
├── networks.tf # Definición de las redes (manage / netstack)
├── variables.tf # Variables ajustables
├── provider.tf # Proveedor libvirt
├── outputs.tf # Outputs útiles (IP, etc.)
├── config/
│ └── cloud_init_simple.cfg # Cloud-init 100% compatible con openSUSE
├── .ssh/
│ ├── id_ed25519
│ └── id_ed25519.pub
├── deploy_opensuse.sh # Script de despliegue automático
├── limpia.sh # Limpieza de recursos
└── local/
└── openSUSE-Leap-15.6.x86_64-NoCloud.qcow2


---

## 🚀 Despliegue

Desde este directorio:

```bash
cd terraform/opensuse
./deploy_opensuse.sh
