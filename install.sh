#!/bin/bash
set -e

# Usage:
# ./install.sh --port 3128 --https-port 3129 --username ghost --password '123456' --whitelist "127.0.0.1,192.168.1.100"
# or with short options:
# ./install.sh -t 3128 -s 3129 -u ghost -p '123456' -w "127.0.0.1,192.168.1.100"

# Default values
HTTP_PORT="3128"
HTTPS_PORT="3129"
USERNAME="ghost"
PASSWORD="123456"
WHITELISTED_IPS="127.0.0.1"

# Parse arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -t|--port)
      HTTP_PORT="$2"
      shift 2
      ;;
    -s|--https-port)
      HTTPS_PORT="$2"
      shift 2
      ;;
    -u|--username)
      USERNAME="$2"
      shift 2
      ;;
    -p|--password)
      PASSWORD="$2"
      shift 2
      ;;
    -w|--whitelist)
      WHITELISTED_IPS="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $key"
      exit 1
      ;;
  esac
done

IFS=',' read -ra WHITELISTED_IPS_ARRAY <<< "$WHITELISTED_IPS"

echo "[*] Installing Squid and dependencies..."
if ! command -v apt &>/dev/null; then
  echo "This script supports only Ubuntu/Debian (apt)."
  exit 1
fi
sudo apt update && sudo apt install -y squid-openssl apache2-utils openssl

echo "[*] Generating SSL certificate..."
SSL_DIR="/etc/squid/ssl_cert"
sudo mkdir -p $SSL_DIR
sudo openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
  -keyout $SSL_DIR/squid.key -out $SSL_DIR/squid.crt \
  -subj "/C=KR/ST=Seoul/L=Seoul/O=Proxy/CN=squidproxy.local"

echo "[*] Creating authentication credentials..."
sudo htpasswd -bc /etc/squid/passwd "$USERNAME" "$PASSWORD"

echo "[*] Backing up original Squid config..."
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

echo "[*] Writing new Squid config..."
sudo tee /etc/squid/squid.conf > /dev/null <<EOF
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm Squid Proxy Server
acl authenticated proxy_auth REQUIRED
acl whitelist_ip src $(IFS=" "; echo "${WHITELISTED_IPS_ARRAY[*]}")
http_port $HTTP_PORT
https_port $HTTPS_PORT cert=$SSL_DIR/squid.crt key=$SSL_DIR/squid.key

http_access allow whitelist_ip
http_access allow authenticated
http_access deny all

cache deny all
cache_dir null /tmp
access_log /var/log/squid/access.log

via off
forwarded_for delete
request_header_access Allow allow all
request_header_access Authorization allow all
request_header_access WWW-Authenticate allow all
request_header_access Proxy-Authorization allow all
request_header_access Proxy-Authenticate allow all
request_header_access Cache-Control allow all
request_header_access Content-Encoding allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Expires allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Last-Modified allow all
request_header_access Location allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Content-Language allow all
request_header_access Mime-Version allow all
request_header_access Retry-After allow all
request_header_access Title allow all
request_header_access Connection allow all
request_header_access Proxy-Connection allow all
request_header_access User-Agent allow all
request_header_access Cookie deny all
request_header_access Referer deny all
EOF

echo "[*] Setting up logrotate..."
sudo tee /etc/logrotate.d/squid > /dev/null <<EOF
/var/log/squid/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 640 proxy proxy
    sharedscripts
    postrotate
        test ! -e /var/run/squid.pid || /usr/sbin/squid -k rotate
    endscript
}
EOF

echo "[*] Restarting and enabling Squid..."
sudo systemctl restart squid
sudo systemctl enable squid

echo "[*] Setting up auto-restart with crontab..."
CRON_JOB="*/30 * * * * systemctl is-active squid || systemctl restart squid"
( crontab -l 2>/dev/null | grep -v 'systemctl is-active squid' ; echo "$CRON_JOB" ) | crontab -

SERVER_IP=$(curl -4 -s ifconfig.me)

echo ""
echo "Setup complete!"
echo "--------------------------------------------"
echo " HTTP Proxy:     http://$SERVER_IP:$HTTP_PORT"
echo " HTTPS Proxy:    https://$SERVER_IP:$HTTPS_PORT"
echo " Username:       $USERNAME"
echo " Password:       $PASSWORD"
echo ""
echo " Whitelisted IPs:"
for ip in "${WHITELISTED_IPS_ARRAY[@]}"; do
    echo "  - $ip (no auth required)"
done
echo ""
echo " Test it with:"
echo " curl -x http://$USERNAME:$PASSWORD@$SERVER_IP:$HTTP_PORT http://ipinfo.io"
echo " curl -k -x https://$USERNAME:$PASSWORD@$SERVER_IP:$HTTPS_PORT https://ipinfo.io"
echo "--------------------------------------------"
echo ""

exit 0
