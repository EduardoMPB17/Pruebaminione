#!/bin/bash
# Script de despliegue automático para MiniOne en Rocky Linux

set -e

echo "🚀 Iniciando despliegue de MiniOne en Rocky Linux..."

# Cambiar al directorio de Terraform
cd "$(dirname "$0")"

# Verificar que existe la imagen de Rocky
if [ ! -f "local/Rocky-9-GenericCloud.latest.x86_64.qcow2" ]; then
    echo "❌ Error: No se encuentra la imagen de Rocky Linux en local/"
    echo "Descargando imagen..."
    wget -O local/Rocky-9-GenericCloud.latest.x86_64.qcow2 \
        "https://dl.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2"
fi

# Verificar que existen las claves SSH
if [ ! -f ".ssh/id_ed25519" ]; then
    echo "❌ Error: No se encuentran las claves SSH en .ssh/"
    echo "Generando claves SSH..."
    ssh-keygen -t ed25519 -f .ssh/id_ed25519 -N ""
fi

echo "1️⃣ Inicializando Terraform..."
terraform init

echo "2️⃣ Validando configuración..."
terraform validate

echo "3️⃣ Planificando despliegue..."
terraform plan

echo "4️⃣ Aplicando configuración..."
terraform apply -auto-approve

echo "5️⃣ Obteniendo IP de la VM..."
VM_IP=$(terraform output -raw ips | tr -d '[]"' | tr -d ' ')
echo "IP de la VM: $VM_IP"

# Esperar a que la VM esté disponible
echo "6️⃣ Esperando que la VM esté disponible..."
for i in {1..60}; do
    if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i .ssh/id_ed25519 vicente@$VM_IP "echo 'VM Ready'" 2>/dev/null; then
        echo "✅ VM disponible"
        break
    fi
    echo "Esperando... ($i/60)"
    sleep 10
done

# Actualizar inventario de Ansible
echo "7️⃣ Actualizando inventario de Ansible..."
sed -i "s/ansible_host=.*/ansible_host=$VM_IP/" ../../ansible/inventory_rocky.yml

# Ejecutar Ansible
echo "8️⃣ Ejecutando instalación con Ansible..."
cd ../../ansible
ansible-playbook -i inventory_rocky.yml install_minione_rocky.yml

echo "🎉 ¡Despliegue completado!"
echo ""
echo "======================================"
echo "Accede a Sunstone en:"
echo "http://$VM_IP:9869"
echo ""
echo "Usuario: oneadmin"
echo "Contraseña: Revisa en la VM en /var/lib/one/.one/one_auth"
echo "======================================"