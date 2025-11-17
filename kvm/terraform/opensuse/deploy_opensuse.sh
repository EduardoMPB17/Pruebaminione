#!/bin/bash
# Script de despliegue automático para MiniOne en openSUSE

set -e

echo "🚀 Iniciando despliegue de MiniOne en openSUSE..."

# Cambiar al directorio de Terraform (donde está este script)
cd "$(dirname "$0")"

# Verificar que existe la imagen de openSUSE
if [ ! -f "local/openSUSE-Leap-15.6.x86_64-NoCloud.qcow2" ]; then
    echo "❌ Error: No se encuentra la imagen de openSUSE en local/"
    echo "Asegúrate de haberla copiado a terraform/opensuse/local/"
    exit 1
fi

# Verificar que existen las claves SSH
if [ ! -f ".ssh/id_ed25519" ]; then
    echo "❌ Error: No se encuentran las claves SSH en .ssh/"
    echo "Generando claves SSH..."
    mkdir -p .ssh
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
VM_IP=""
COUNT=0
MAX_WAIT=30 # Esperar 30 intentos (60 segundos)
while [ -z "$VM_IP" ]; do
  # El 'terraform output -raw' ahora funciona gracias al try() en outputs.tf
  VM_IP=$(terraform output -raw ips)
  
  if [ -z "$VM_IP" ]; then
    COUNT=$((COUNT+1))
    if [ $COUNT -gt $MAX_WAIT ]; then
      echo "❌ ERROR: Límite de tiempo esperando la IP. La VM no arrancó o cloud-init falló."
      echo "Inicia la depuración manual. Ejecuta 'sudo virt-viewer minione-suse' para ver la consola."
      exit 1
    fi
    echo "Esperando IP... (Intento $COUNT/$MAX_WAIT)"
    sleep 2
  fi
done
echo "✅ IP de la VM obtenida: $VM_IP"

# Esperar a que la VM esté disponible para SSH
echo "6️⃣ Esperando que SSH esté disponible..."
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
# (Asegúrate que tu inventory_opensuse.yml tenga la línea 'ansible_host:')
sed -i "s/ansible_host:.*/ansible_host: $VM_IP/" ../../ansible/inventory_opensuse.yml

# Ejecutar Ansible
echo "8️⃣ Ejecutando instalación con Ansible..."
cd ../../ansible
ansible-playbook -i inventory_opensuse.yml install_minione_opensuse.yml

echo "🎉 ¡Despliegue completado!"
echo ""
echo "======================================"
echo "Accede a Sunstone en:"
echo "http://$VM_IP:9869"
echo ""
echo "Usuario: oneadmin"
echo "Contraseña: Revisa en la VM en /var/lib/one/.one/one_auth"
echo "======================================"