#!/bin/bash

# Usage:
# ./install.sh --port 3128 --username ghost --password '123456' --whitelist "127.0.0.1,192.168.1.100"
#
# Default values:
PROXY_PORT="3128"
USERNAME="ghost"
PASSWORD="123456"
WHITELISTED_IPS="127.0.0.1"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --port)
      PROXY_PORT="$2"
      shift
      shift
      ;;
    --username)
      USERNAME="$2"
      shift
      shift
      ;;
    --password)
      PASSWORD="$2"
      shift
      shift
      ;;
    --whitelist)
      WHITELISTED_IPS="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown option: $key"
      exit 1
      ;;
  esac
done

# Convert comma-separated whitelist IPs string to an array
IFS=',' read -ra WHITELISTED_IPS_ARRAY <<< "$WHITELISTED_IPS"

echo "[*] Installing Squid, Apache utils, UFW, Fail2Ban..."
sudo apt update && sudo apt install -y squid apache2-utils ufw fail2ban

echo "[*] Creating authentication credentials..."
sudo htpasswd -bc /etc/squid/passwd "$USERNAME" "$PASSWORD"

echo "[*] Backing up original Squid config..."
sudo cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

echo "[*] Writing secure Squid config with whitelist + auth..."
sudo tee /etc/squid/squid.conf > /dev/null <<EOF
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
auth_param basic realm Squid Proxy Server
acl authenticated proxy_auth REQUIRED
EOF

for ip in "${WHITELISTED_IPS_ARRAY[@]}"; do
    echo "acl whitelist_ip src $ip" | sudo tee -a /etc/squid/squid.conf > /dev/null
done

sudo tee -a /etc/squid/squid.conf > /dev/null <<EOF

http_port $PROXY_PORT

http_access allow whitelist_ip
http_access allow authenticated
http_access deny all

access_log /var/log/squid/access.log

# Anonymous headers (privacy protection)
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

echo "[*] Configuring UFW firewall..."
sudo ufw allow OpenSSH
sudo ufw allow "$PROXY_PORT"
sudo ufw --force enable

echo "[*] Setting up logrotate for 30-day retention..."
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

echo "[*] Enabling and restarting Squid..."
sudo systemctl restart squid
sudo systemctl enable squid

echo "[*] Setting up auto-restart with crontab..."
(crontab -l 2>/dev/null; echo "*/30 * * * * systemctl is-active squid || sudo systemctl restart squid") | crontab -

SERVER_IP=$(curl -4 -s ifconfig.me)

echo ""
echo "Setup complete!"
echo "--------------------------------------------"
echo " Proxy address:  http://$SERVER_IP:$PROXY_PORT"
echo " Username:       $USERNAME"
echo " Password:       $PASSWORD"
echo ""
echo " Whitelisted IPs:"
for ip in "${WHITELISTED_IPS_ARRAY[@]}"; do
    echo "  - $ip (no auth required)"
done
echo ""
echo " Test it with:"
echo " curl -x http://$USERNAME:$PASSWORD@$SERVER_IP:$PROXY_PORT http://ipinfo.io"
echo "--------------------------------------------"
echo ""
