#!/bin/bash

# Script para resetear huellas SSH - acepta IP como parámetro
# Uso: ./reset_ssh_finger_flexible.sh <IP> [usuario] [contraseña]

if [ $# -eq 0 ]; then
    echo "❌ Uso: $0 <IP> [usuario] [contraseña]"
    echo "Ejemplo para Ubuntu: $0 172.16.25.2 vicente 123"
    echo "Ejemplo para Rocky:  $0 172.16.25.61 vicente 123"
    exit 1
fi

host=$1
user=${2:-vicente}
pass=${3:-123}

echo "🧹 Limpiando huella SSH para $host..."
ssh-keygen -f "$HOME/.ssh/known_hosts" -R $host

echo "🔗 Probando conexión SSH como $user@$host..."
sshpass -p "$pass" ssh -o StrictHostKeyChecking=no $user@$host "echo \"✅ Reset SSH exitoso - \$(uname -a)\""