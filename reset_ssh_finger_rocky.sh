#!/bin/bash

host=172.16.25.61

echo "🧹 Limpiando huella SSH para Rocky Linux ($host)..."
ssh-keygen -f "$HOME/.ssh/known_hosts" -R $host

echo "🔗 Probando conexión SSH..."
sshpass -p "123" ssh -o StrictHostKeyChecking=no vicente@$host 'echo "✅ Reset SSH Rocky Linux exitoso - $(uname -a)"'