#!/bin/bash
# Script de limpieza MANUAL (a prueba de fallos y zombies) para OpenSUSE

echo "🧹 Limpiando recursos de OpenSUSE (Modo Manual)..."

# 1. Matar procesos zombies de QEMU que usen 'minione-suse'
echo "💀 Matando procesos zombies..."
ps aux | grep "qemu-system-x86_64" | grep "minione-suse" | awk '{print $2}' | xargs -r sudo kill -9

# 2. Destruir la VM (dominio)
echo "💥 Destruyendo VM 'minione-suse'..."
sudo virsh destroy minione-suse 2>/dev/null || echo "VM no estaba corriendo."
sudo virsh undefine minione-suse --nvram 2>/dev/null || echo "VM no estaba definida."

# 3. Destruir los Discos (volúmenes)
echo "🗑️ Destruyendo volúmenes del pool 'pool'..."
# Intentamos borrar vía virsh primero
sudo virsh vol-delete --pool pool minione-suse-commoninit.iso 2>/dev/null || echo "Volumen ISO no encontrado."
sudo virsh vol-delete --pool pool minione-suse-os_image_v2 2>/dev/null || echo "Volumen de OS no encontrado."

# Si virsh falla (por locks residuales), borramos los archivos a la fuerza
# Asegúrate de que esta ruta sea correcta: /home/vicente/vmstore/pool/
sudo rm -f /home/vicente/vmstore/pool/minione-suse-os_image_v2
sudo rm -f /home/vicente/vmstore/pool/minione-suse-commoninit.iso

# 4. Limpiar estado de Terraform
echo "🧹 Limpiando estado de Terraform..."
rm -f terraform.tfstate
rm -f terraform.tfstate.backup
rm -f .terraform.lock.hcl

echo "✅ Limpieza manual completada."