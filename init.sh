#!/bin/bash
dnf update -y
dnf install -y httpd
echo "hello world 1a" > /var/www/html/index.html 
chown -R apache:apache /var/www/html
systemctl enable httpd
systemctl start httpd
