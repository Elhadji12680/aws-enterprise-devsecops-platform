#!/bin/bash
yum update -y
yum install -y httpd wget unzip
systemctl enable httpd
systemctl start httpd
cd /tmp
wget https://github.com/Ahmednas211/jupiter-zip-file/raw/main/jupiter-main.zip
unzip -o jupiter-main.zip
rm -rf /var/www/html/*
cp -r jupiter-main/* /var/www/html/
rm -rf jupiter-main jupiter-main.zip
systemctl restart httpd