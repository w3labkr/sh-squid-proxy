# Squid Proxy Installer

This project provides a script that automatically installs and configures a Squid proxy server on Ubuntu/Debian-based Linux systems. It supports username/password authentication, optional IP whitelisting, and HTTPS proxying via SSL-Bump. The script is production-ready and includes features for reliable and secure proxy operations.

## Key Features

- **Automated Installation:** Installs and configures Squid with authentication and SSL support.
- **Customizable via Command-Line Flags:**
  - `--port` / `-t`: Set HTTP proxy port (default: `3128`)
  - `--https-port` / `-s`: Set HTTPS proxy port (default: `3129`)
  - `--username` / `-u`: Set authentication username (default: `ghost`)
  - `--password` / `-p`: Set authentication password (default: `123456`)
  - `--whitelist` / `-w`: Comma-separated list of IPs that bypass authentication (default: `127.0.0.1`)
- **Automatic Public IPv4 Detection:** Uses `curl -4 -s ifconfig.me` to display your server’s public IP.
- **Log Management:** Uses logrotate to retain logs for 30 days.
- **HTTP Header Stripping:** Improves anonymity by removing unnecessary HTTP headers.
- **Automatic Service Recovery:** A cron job monitors and restarts Squid if it stops.
- **HTTPS Proxy Support:** Generates a self-signed certificate and enables SSL proxying.

## System Requirements

- Ubuntu 20.04 / 22.04 / 24.04 or Debian-based system
- Public IPv4 address (e.g., VPS or cloud instance)
- Sudo privileges

## Installation

```bash
sudo apt update && sudo apt install -y git
git clone https://github.com/w3labkr/sh-squid-proxy-installer.git
cd sh-squid-proxy-installer
chmod +x install.sh
```

## Usage

You can customize the installation using command-line options. If no options are provided, default values are used.

### Command-Line Options

| Option (long/short) | Description                                 | Default      |
|---------------------|---------------------------------------------|--------------|
| --port, -t          | HTTP proxy port                             | 3128         |
| --https-port, -s    | HTTPS proxy port                            | 3129         |
| --username, -u      | Authentication username                     | ghost        |
| --password, -p      | Authentication password                     | 123456       |
| --whitelist, -w     | Comma-separated list of IPs to whitelist    | 127.0.0.1    |

**Example:**

```bash
./install.sh --port 3128 --https-port 3129 --username ghost --password '123456' --whitelist "127.0.0.1,192.168.1.100"
# or
./install.sh -t 3128 -s 3129 -u ghost -p '123456' -w "127.0.0.1,192.168.1.100"
```

During execution, the script automatically detects your server’s public IPv4 address and displays proxy connection details.

## Post-Installation Configuration

You can update authentication details, modify the whitelist IPs, or change the proxy ports at any time.

### Update Username / Password

**To add a new user:**

```bash
sudo htpasswd /etc/squid/passwd newuser
```

**To change an existing user's password:**

```bash
sudo htpasswd /etc/squid/passwd ghost
```

*Changes are applied immediately without the need to restart Squid.*

### Modify Whitelisted IPs

Edit `/etc/squid/squid.conf` and update the `acl whitelist_ip src ...` line.  
List multiple IPs as a space-separated list (as generated by the script):

```conf
acl whitelist_ip src 127.0.0.1 123.123.123.123 45.67.89.101
```

Restart Squid to apply changes:

```bash
sudo systemctl restart squid
```

### Change the Proxy Port

Edit the following lines in `/etc/squid/squid.conf`:

```conf
http_port 3128
https_port 3129 cert=/etc/squid/ssl_cert/squid.crt key=/etc/squid/ssl_cert/squid.key
```

Restart Squid:

```bash
sudo systemctl restart squid
```

## Example Usage

Using cURL

```bash
curl -x http://ghost:123456@<proxy_server_ip>:3128 http://ipinfo.io
curl -k -x https://ghost:123456@<proxy_server_ip>:3129 https://ipinfo.io
```

Using Python requests

```python
import requests

proxies = {
    "http": "http://ghost:123456@<proxy_server_ip>:3128",
    "https": "https://ghost:123456@<proxy_server_ip>:3129"
}

response = requests.get("http://ipinfo.io", proxies=proxies)
print(response.text)
```

## Additional Information

- **Log Management:** Log files are rotated and retained for 30 days via logrotate.
- **Service Recovery:** A cron job checks Squid every 30 minutes and restarts it if needed.
- **HTTPS Proxy Support:** The script sets up a self-signed certificate for SSL-Bump and enables a secure HTTPS proxy port.
- **Public IP Auto-Detection:** The script retrieves your server’s public IPv4 address with `curl -4 -s ifconfig.me`.
- **Script Exit:** The script ends with `exit 0` to indicate successful execution.

## Auto Setup with Startup Script

You can use the following startup script on cloud platforms to automate installation:

```bash
#!/bin/bash

sudo apt update && sudo apt install -y git
cd /root || exit
git clone https://github.com/w3labkr/sh-squid-proxy-installer.git
cd sh-squid-proxy-installer || exit
chmod +x install.sh
./install.sh -t 3128 -s 3129 -u ghost -p '123456' -w "127.0.0.1"
```

Test the Proxy Server

```bash
curl -x http://ghost:123456@<proxy_server_ip>:3128 http://ipinfo.io
curl -k -x https://ghost:123456@<proxy_server_ip>:3129 https://ipinfo.io
```

## Troubleshooting

- **Only Ubuntu/Debian Supported:** The script checks for `apt` and will exit if not found.
- **Firewall:** Ensure your firewall allows inbound connections on the chosen proxy ports.
- **Certificate Warnings:** The HTTPS proxy uses a self-signed certificate. Use `-k` with curl or configure your client to trust the certificate if needed.

## License

This project is licensed under the [MIT License](LICENSE).  
Feel free to use and modify the script as needed.