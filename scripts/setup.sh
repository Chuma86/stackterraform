#!/bin/bash
set -euxo pipefail

############################################################
# Install base packages (Golden AMI)
############################################################
sudo dnf upgrade -y
sudo dnf install -y httpd wget git php php-fpm php-mysqli php-json php-devel mariadb105-server nmap-ncat

############################################################
# Enable and start Apache
############################################################
sudo systemctl enable --now httpd

############################################################
# Apache configuration
############################################################
sudo sed -i '151s/None/All/' /etc/httpd/conf/httpd.conf

############################################################
# Permissions for /var/www (WordPress + EFS ready)
############################################################
sudo usermod -a -G apache ec2-user
sudo chown -R apache:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \; && find /var/www -type f -exec sudo chmod 0664 {} \;

############################################################
# TCP keepalive tuning
############################################################
sudo sysctl -w net.ipv4.tcp_keepalive_time=200 net.ipv4.tcp_keepalive_intvl=200 net.ipv4.tcp_keepalive_probes=5

############################################################
# Restart Apache
############################################################
sudo systemctl restart httpd
