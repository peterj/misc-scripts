#!/bin/bash
# Prerequisite for add-apt-repository
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-nginx

# Allow https through the firewall
sudo ufw allow 'Nginx Full'

# Remove HTTP endpoint
sudo ufw delete allow 'Nginx HTTP'
