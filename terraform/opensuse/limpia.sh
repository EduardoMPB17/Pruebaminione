#!/bin/bash
# Script de limpieza para Rocky Linux

echo "🧹 Limpiando recursos de Rocky Linux..."

# Destruir infraestructura de Terraform
echo "Destruyendo VMs..."
terraform destroy -auto-approve

# Limpiar archivos de estado temporal
echo "Limpiando archivos temporales..."
rm -f terraform.tfstate.backup
rm -f .terraform.lock.hcl

# Limpiar logs
echo "Limpiando logs..."
sudo rm -f /tmp/minione

echo "✅ Limpieza completada para Rocky Linux"