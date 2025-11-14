# Las redes 'manage' y 'netstack' deben existir previamente
# Estas son gestionadas por el proyecto Ubuntu o creadas manualmente

# Si necesitas crearlas manualmente, ejecuta:
# sudo virsh net-define /dev/stdin <<EOF
# <network>
#   <name>manage</name>
#   <forward mode='nat'/>
#   <bridge name='virbr1' stp='on' delay='0'/>
#   <domain name='manage.local'/>
#   <ip address='172.16.25.1' netmask='255.255.255.0'>
#     <dhcp>
#       <range start='172.16.25.2' end='172.16.25.254'/>
#     </dhcp>
#   </ip>
# </network>
# EOF
# sudo virsh net-start manage
# sudo virsh net-autostart manage

# Similar para netstack con 172.16.100.0/24