#!/bin/bash
# Script de limpieza MANUAL

echo "🧹 Limpiando recursos..."


# 4. Limpiar Terraform
rm -f terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl .terraform/

echo "✅ Limpieza completada."