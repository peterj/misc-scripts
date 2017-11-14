#!/bin/bash
DOMAIN_NAME=$1
sudo certbot --nginx -d $DOMAIN_NAME -d www.$DOMAIN_NAME

# Check that renewal works
sudo certbot renew --dry-run