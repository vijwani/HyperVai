#!/bin/bash
sudo apt update -y
sudo apt-get install cloud-utils -y
sudo apt-cache search apache
sudo apt-get install apache2 -y
sudo touch /var/www/html/index.html
sudo chmod 777 /var/www/html/index.html
echo "<h3><b>IpAddress is </b></h3>" | tee /var/www/html/index.html
sudo hostname -i | tee -a /var/www/html/index.html
echo "<br><h3><b> MacAdress is </b></h3>" | tee -a /var/www/html/index.html
sudo ip link show | tee -a /var/www/html/index.html
echo "<br><h3><b> Instance id is </b></h3>" | tee -a /var/www/html/index.html
sudo ec2metadata --instance-id | tee -a /var/www/html/index.html