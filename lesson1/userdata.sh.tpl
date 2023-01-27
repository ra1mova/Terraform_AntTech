#!/bin/bash
sudo su
apt update -y
apt install apache2 -y
apt install wget -y
apt install unzip -y
systemctl start apache2
systemctl enable apache2 
wget https://github.com/ra1mova/portfolio/archive/refs/heads/main.zip 
unzip main.zip
A
cd portfolio-main
mv README.md css/ fetch.html image/ index.html js/ shop.html /var/www/html/