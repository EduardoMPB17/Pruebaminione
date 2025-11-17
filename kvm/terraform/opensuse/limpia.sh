#!/bin/bash
# Script de limpieza MANUAL

echo "🧹 Limpiando recursos..."

# 1. Matar zombies
sudo killall -9 qemu-system-x86_64 2>/dev/null

# 2. Destruir VM
sudo virsh destroy minione-suse 2>/dev/null
sudo virsh undefine minione-suse --nvram 2>/dev/null

# 3. Destruir Discos (En el pool default)
sudo virsh vol-delete --pool default minione-suse-commoninit.iso 2>/dev/null
sudo virsh vol-delete --pool default minione-suse-os_image_v3 2>/dev/null

# Por si acaso, borrado manual
sudo rm -f /var/lib/libvirt/images/minione-suse-os_image_v3
sudo rm -f /var/lib/libvirt/images/minione-suse-commoninit.iso

# 4. Limpiar Terraform
rm -f terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl

echo "✅ Limpieza completada."