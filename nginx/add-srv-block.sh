#!/bin/bash
define ()
{
  IFS=$'\n' read -r -d '' $1
}

DOMAIN_NAME=$1
PORT=80
WWW_ROOT="/var/www/$DOMAIN_NAME/html"
SITES_AVAILABLE="/etc/nginx/sites-available"
SITES_ENABLED="/etc/nginx/sites-enabled"

# sudo mkdir -p $WWW_ROOT
# sudo chown -R $USER:$USER $WWW_ROOT
# sudo chmod -R 755 /var/www

# ---------- Create sample HTML file contents ----------
define HTML_CONTENTS<<EOT
<html>
    <head>
        <title>Welcome to ${DOMAIN_NAME}</title>
    </head>
    <body>
        <h1>Hello</h1>
    </body>
</html>
EOT

printf "%s\n" "$HTML_CONTENTS" >> $DOMAIN_NAME.html
# sudo cp $DOMAIN_NAME.html $WWW_ROOT/index.html

# ---------- Create a server block ----------
define SERVER_BLOCK<<EOT
server {
        listen ${PORT};
        listen [::]:${PORT};

        root /var/www/${DOMAIN_NAME}html;
        index index.html index.htm index.nginx-debian.html;

        server_name ${DOMAIN_NAME} www.${DOMAIN_NAME};

        location / {
                try_files $uri $uri/ =404;
        }
}
EOT
printf "%s\n" "$SERVER_BLOCK" >> $DOMAIN_NAME
sudo cp $DOMAIN_NAME $SITES_AVAILABLE/$DOMAIN_NAME

# Link the config
sudo ln -s $SITES_AVAILABLE/$DOMAIN_NAME $SITES_ENABLED/