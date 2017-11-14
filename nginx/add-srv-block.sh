#!/bin/bash
#!/bin/bash
set -eo pipefail
IFS=$'\n\t'

readonly LOG_FILE="/tmp/$(basename "$0").log"
info()    { echo "[INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $*" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $*" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $*" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

printUsage() {
    cat << EOF
Usage:
        ${0##*/} [-d DOMAIN_NAME] [-p PORT]
        
Creates an Nginx server block
        -d DOMAIN_NAME    Domain name (without www)
        -p PORT           Port number (default: 80)
EOF
}

cleanup() {
    info "Done."
}

define ()
{
  IFS=$'\n' read -r -d '' $1
}

PORT=80

OPTIND=1
while getopts ":d:p:h" opt; do
    case $opt in
        d) DOMAIN_NAME=$OPTARG
           ;;
        p) PORT=$OPTARG
           ;;
        h) printUsage; exit 0
           ;;
        \?)
            error "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"

if [ -z "$DOMAIN_NAME" ]
then
   printUsage;
   exit
fi


if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT

    WWW_ROOT="/var/www/$DOMAIN_NAME/html"
    SITES_AVAILABLE="/etc/nginx/sites-available"
    SITES_ENABLED="/etc/nginx/sites-enabled"

    info "Create $WWW_ROOT"
    sudo mkdir -p $WWW_ROOT
    sudo chown -R $USER:$USER $WWW_ROOT
    sudo chmod -R 755 /var/www

    # ---------- Create sample HTML file contents ----------
    info "Write sample index.html to $DOMAIN_NAME.html"
    cat <<EOF > $DOMAIN_NAME.html
    <html>
        <head>
            <title>Welcome to ${DOMAIN_NAME}</title>
        </head>
        <body>
            <h1>Hello</h1>
        </body>
    </html>
EOF
    info "Copy $DOMAIN_NAME.html to $WWW_ROOT/index.html"
    sudo cp $DOMAIN_NAME.html $WWW_ROOT/index.html

    # ---------- Create a server block ----------
    info "Write server block to $DOMAIN_NAME"
    cat <<EOF > $DOMAIN_NAME
    server {
        listen ${PORT};
        listen [::]:${PORT};

        root /var/www/${DOMAIN_NAME}/html;
        index index.html index.htm index.nginx-debian.html;

        server_name ${DOMAIN_NAME} www.${DOMAIN_NAME};

        location / {
                try_files $uri $uri/ =404;
        }
    }
EOF
    info "Copy $DOMAIN_NAME to $SITES_AVAILABLE/$DOMAIN_NAME"
    sudo cp $DOMAIN_NAME $SITES_AVAILABLE/$DOMAIN_NAME

    info "Link the config to $SITES_ENABLED"
    sudo ln -s $SITES_AVAILABLE/$DOMAIN_NAME $SITES_ENABLED/
fi
