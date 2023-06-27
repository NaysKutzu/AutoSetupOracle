#!/bin/bash
set -e

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

echo "      Welcome to SuperHori Script"
echo "With this script, you can set up your server."

# Wait for user input before proceeding
read -p "Press any key to start installing ..."

# Configure SSH
cd /etc/ssh
rm sshd_config
curl -o sshd_config https://raw.githubusercontent.com/superhori69/AutoSetupOracle/main/sshd_config
systemctl restart ssh
systemctl restart sshd
echo "We enabled root login and password authentication."

# Set root password
echo "Let's set up a password!"
passwd

# Install required packages and repositories
apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
add-apt-repository ppa:redislabs/redis -y
apt-add-repository universe
curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash

# Install necessary packages
apt -y install php8.1 php8.1-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} nginx certbot python3-certbot-nginx iptables mariadb-server tar unzip git iptables-persistent

# Perform system updates
sudo apt update
sudo apt -y upgrade

# Configure iptables
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
sudo iptables -t nat -F
sudo iptables -t mangle -F
sudo iptables -F
sudo iptables -X
iptables-save > /etc/iptables/rules.v4

# Script execution completed successfully
echo "Server setup completed successfully!"

# Prompt user for next action
echo "Choose an option:"
echo "1. Continue using the server."
echo "2. Restart the server."
read -p "Enter your choice (1 or 2): " choice

if [[ $choice -eq 1 ]]; then
  echo "Continuing to use the server."
elif [[ $choice -eq 2 ]]; then
  echo "Restarting the server..."
  reboot
else
  echo "Invalid choice. Exiting."
  exit 1
fi
# END