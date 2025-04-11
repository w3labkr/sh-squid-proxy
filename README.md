# Squid Proxy Installer

This project provides a script that **automatically installs a Squid proxy server** on **Ubuntu-based Linux systems**. It supports **ID/password authentication**, making it highly reliable even in environments with dynamic IP addresses. The script also includes a number of features that are particularly useful for real-world web crawling and proxy server operations.

## Key Features

- **Automated installation** of a Squid proxy server with **ID/password authentication**
- **Customizable proxy port** (default: `3128`) – useful for avoiding detection on common ports
- **30-day log retention** using `logrotate`
- **Enhanced SSH security** with `Fail2ban` – helps prevent brute-force login attempts
- **Header stripping** for improved anonymity
- **Automatic service recovery** on failure via `crontab`

## Installation

Install Git (if not already installed)

```bash
sudo apt update && sudo apt install -y git
```

Clone the repository

```bash
git clone https://github.com/w3labkr/sh-squid-proxy.git
cd sh-squid-proxy
```

Make the script executable and configure the settings

```bash
chmod +x install.sh
```

To generate a random password on Ubuntu:

```bash
echo "PASSWORD: $(< /dev/urandom tr -dc 'A-Za-z0-9' | head -c 16)"
```

You can edit the `install.sh` script to change the username, password, and proxy port before installation.

```bash
$ vim ./install.sh
PROXY_PORT="3128"
USERNAME="ghost"
PASSWORD="password"
WHITELISTED_IPS=("127.0.0.1")
```

Run the installer

```bash
./install.sh
```

## Configuration

After installation, you can update authentication details, whitelist IPs, or change the proxy port at any time.

### Update Username / Password

To add a new user:

```bash
sudo htpasswd /etc/squid/passwd newuser
```

To remove a user, edit the password file manually:

```bash
sudo vim /etc/squid/passwd
```

To change a user's password:

```bash
sudo htpasswd /etc/squid/passwd ghost
```

> Changes take effect immediately—no need to restart the service.

### Modify Whitelisted IPs

Edit the Squid configuration file at `/etc/squid/squid.conf`:

```conf
acl whitelist_ip src 127.0.0.1
```

To add multiple IPs:

```conf
acl whitelist_ip src 127.0.0.1
acl whitelist_ip src 123.123.123.123
acl whitelist_ip src 45.67.89.101
```

Apply changes by restarting Squid:

```bash
sudo systemctl restart squid
```

### Change Proxy Port

Common Proxy Ports

| Port Number | Description                          |
|-------------|--------------------------------------|
| 3128        | Default Squid proxy port             |
| 8080        | Common HTTP proxy port               |
| 8888        | Often used for development/testing   |
| 8000        | Common for local web servers         |
| 1080        | Typical SOCKS4/5 proxy port          |
| 443         | Standard HTTPS port                  |
| 50000       | High-numbered port for local testing |
| 54321       | Easy-to-remember test port           |
| 60000       | Great for custom proxy setups        |

Open `/etc/squid/squid.conf` and update the port setting:

```conf
http_port 3128 → http_port 8888
```

Allow the new port through your firewall:

```bash
sudo ufw allow 8888
sudo ufw delete allow 3128  # Optional: remove old port rule
```

Then restart the Squid service:

```bash
sudo systemctl restart squid
```

## Example Usage

Using `curl`:

```bash
curl -x http://ghost:password@<your-server-ip>:3128 http://ipinfo.io
```

Using Python `requests`:

```python
import requests

proxies = {
    "http": "http://ghost:password@<your-server-ip>:3128",
    "https": "http://ghost:password@<your-server-ip>:3128"
}

res = requests.get("http://ipinfo.io", proxies=proxies)
print(res.text)
```

## System Requirements

- Ubuntu 20.04 / 22.04 / 24.04 or later
- A server with a public IP address (e.g., VPS or cloud instance)
- A user account with `sudo` privileges

## Security & Operational Tips

- It’s recommended to change the default SSH port and use key-based SSH authentication.
- `Fail2ban` is pre-configured to protect SSH access.
- For high-traffic environments, consider setting connection limits.
- On public or multi-user servers, implement strict access controls.

## License

This project is licensed under the [MIT License](LICENSE).  
Feel free to use and modify the script, but do so at your own risk.
