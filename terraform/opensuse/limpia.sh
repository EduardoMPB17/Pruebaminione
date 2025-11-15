#!/bin/bash
# Script de limpieza MANUAL (a prueba de fallos) para OpenSUSE

echo "🧹 Limpiando recursos de OpenSUSE (Modo Manual)..."

# 1. Destruir la VM (dominio)
echo "Destruyendo VM 'minione-suse'..."
sudo virsh destroy minione-suse || echo "VM no estaba corriendo."
sudo virsh undefine minione-suse || echo "VM no estaba definida."

# 2. Destruir la Red
echo "Destruyendo red 'netstack'..."
sudo virsh net-destroy netstack || echo "Red no estaba activa."
sudo virsh net-undefine netstack || echo "Red no estaba definida."

# 3. Destruir los Discos (volúmenes)
echo "Destruyendo volúmenes del pool 'pool'..."
sudo virsh vol-delete --pool pool minione-suse-commoninit.iso || echo "Volumen ISO no encontrado."
sudo virsh vol-delete --pool pool minione-suse-os_image || echo "Volumen de OS no encontrado."

# 4. Limpiar estado de Terraform
echo "Limpiando estado de Terraform..."
rm -f terraform.tfstate
rm -f terraform.tfstate.backup
rm -f .terraform.lock.hcl

echo "✅ Limpieza manual completada."