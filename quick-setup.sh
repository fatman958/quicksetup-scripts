setup_dhcp() {
    echo "Configuring DHCP..."
    
    # For netplan (Ubuntu 20.04+)
    if command -v netplan &> /dev/null; then
        sudo bash -c 'cat > /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
EOF'
        sudo netplan apply
    # Fallback to ifupdown
    else
        sudo bash -c 'cat > /etc/network/interfaces << EOF
auto eth0
iface eth0 inet dhcp
EOF'
        sudo systemctl restart networking
    fi
    echo "DHCP configured successfully!"
}

# Function to configure static IP
setup_static_ip() {
    echo "Enter static IP address (e.g., 192.168.1.100):"
    read -r IP_ADDRESS
    
    echo "Enter subnet mask/CIDR (e.g., 24 or 255.255.255.0):"
    read -r SUBNET
    
    echo "Enter gateway (e.g., 192.168.1.1):"
    read -r GATEWAY
    
    echo "Enter DNS servers (e.g., 8.8.8.8 8.8.4.4):"
    read -r DNS_SERVERS
    
    echo "Configuring static IP..."
    
    if command -v netplan &> /dev/null; then
        sudo bash -c "cat > /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses: [$IP_ADDRESS/$SUBNET]
      gateway4: $GATEWAY
      nameservers:
        addresses: [$DNS_SERVERS]
EOF"
        sudo netplan apply
    else
        sudo bash -c "cat > /etc/network/interfaces << EOF
auto eth0
iface eth0 inet static
    address $IP_ADDRESS
    netmask $SUBNET
    gateway $GATEWAY
    dns-nameservers $DNS_SERVERS
EOF"
        sudo systemctl restart networking
    fi
    echo "Static IP configured successfully!"
}

check_done(){
    input "You done? (y/n): " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 1
    fi
}

sudo apt update
sudo apt upgrade -y

echo "Installing dependencies..."

input "Do you want to setup and install ssh? (y/n): " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing dependencies..."
    sudo apt install openssh-server -y
    sudo systemctl enable ssh
    sudo systemctl start ssh
else
    echo "Skipping."
fi

read -p "Do you want to use DHCP ip address? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    setup_dhcp
else
    read -p "Do you want to configure static IP? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_static_ip
    else
        echo "Skipping network configuration."
    fi
fi

check_done

input "Do you want to setup untattended-upgrades? (y/n): " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing dependencies..."
    sudo apt install unattended-upgrades -y
    sudo systemctl enable unattended-upgrades
    sudo systemctl start unattended-upgrades
    sudo dpkg-reconfigure --priority=low unattended-upgrades
else
    echo "Skipping."
fi

check_done

input "Do you want to install docker? (y/n): " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing dependencies..."
    sudo apt install docker-compose -y
    sudo apt install docker.io
else
    echo "Skipping."
fi

done


echo "Setup complete! Please reboot your system for all changes to take effect."
