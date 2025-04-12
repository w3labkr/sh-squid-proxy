# Squid Proxy Installer

This project provides a script that automatically installs a Squid proxy server on Ubuntu-based Linux systems. It supports username/password authentication, making it highly reliable even in dynamic IP environments. The script is also packed with useful features for real-world web crawling and proxy operations.

## Key Features

- **Automated Installation:** Installs and configures a Squid proxy server with username/password authentication.
- **Customizable Settings via Command-Line Flags:**
  - `--port` (short option: `-t`): Set the proxy port (default: `3128`).
  - `--username` (short option: `-u`): Set the authentication username (default: `ghost`).
  - `--password` (short option: `-p`): Set the authentication password (default: `123456`).
  - `--whitelist` (short option: `-w`): Comma-separated list of IP addresses that bypass authentication (default: `127.0.0.1`).
- **Automatic Public IPv4 Detection:** Uses `curl -4 -s ifconfig.me` to automatically retrieve and display the server’s public IPv4 address.
- **30-Day Log Retention:** Configured via `logrotate` for efficient log management.
- **Enhanced SSH Security:** Implements Fail2ban to help prevent brute-force login attempts.
- **HTTP Header Stripping:** Improves anonymity by removing unnecessary HTTP headers.
- **Automatic Service Recovery:** A cron job monitors the Squid service and restarts it if it stops unexpectedly.

## Installation

### System Requirements

- Ubuntu 20.04 / 22.04 / 24.04 or later.
- A server with a public IPv4 address (e.g., VPS or cloud instance).
- A user account with sudo privileges.

### Installation Steps

**Install Git:**

```bash
sudo apt update -y && sudo apt install -y git
```

**Clone the repository:**

```bash
git clone https://github.com/w3labkr/sh-squid-proxy.git
cd sh-squid-proxy
```

**Make the script executable:**

```bash
chmod +x install.sh
```

## Usage

The script supports both long and short command-line options to customize the installation. If no flags are provided, default values will be applied.

### Command-Line Options

- **Long Options:**
  - `--port`: Proxy port (default: `3128`)
  - `--username`: Authentication username (default: `ghost`)
  - `--password`: Authentication password (default: `123456`)
  - `--whitelist`: Comma-separated list of IP addresses that can bypass authentication (default: `127.0.0.1`)
- **Short Options:**
  - `-t`: Proxy port
  - `-u`: Authentication username
  - `-p`: Authentication password
  - `-w`: Whitelist IPs

**Example:**

```bash
./install.sh --port 3128 --username ghost --password '123456' --whitelist "127.0.0.1,192.168.1.100"
```

Or using short options:

```bash
./install.sh -t 3128 -u ghost -p '123456' -w "127.0.0.1,192.168.1.100"
```

During execution, the script automatically detects your server’s public IPv4 address and incorporates it into the output for easy proxy configuration.

## Post-Installation Configuration

You can update authentication details, modify the whitelist IPs, or change the proxy port at any time.

### Update Username / Password

**To add a new user:**

```bash
sudo htpasswd /etc/squid/passwd newuser
```

**To change an existing user's password:**

```bash
sudo htpasswd /etc/squid/passwd ghost
```

*Changes are applied immediately without the need to restart the Squid service.*

### Modify Whitelisted IPs

Edit the Squid configuration file at `/etc/squid/squid.conf`. For example:

```conf
acl whitelist_ip src 127.0.0.1
```

To add multiple IPs, list them as separate ACL entries:

```conf
acl whitelist_ip src 127.0.0.1
acl whitelist_ip src 123.123.123.123
acl whitelist_ip src 45.67.89.101
```

Apply the changes by restarting Squid:

```bash
sudo systemctl restart squid
```

### Change the Proxy Port

Update the `http_port` setting in `/etc/squid/squid.conf`:

```conf
http_port 3128 → http_port 8888
```

Allow the new port through your firewall:

```bash
sudo ufw allow 8888
sudo ufw delete allow 3128  # (optional: remove the old rule)
```

Restart the Squid service:

```bash
sudo systemctl restart squid
```

## Example Usage

### Using cURL

```bash
curl -x http://ghost:123456@<your-server-ip>:3128 http://ipinfo.io
```

### Using Python requests

```python
import requests

proxies = {
    "http": "http://ghost:123456@<your-server-ip>:3128",
    "https": "http://ghost:123456@<your-server-ip>:3128"
}

response = requests.get("http://ipinfo.io", proxies=proxies)
print(response.text)
```

## Additional Information

- **UFW Configuration:** The script configures UFW to allow both OpenSSH and the specified proxy port.
- **Log Management:** Uses logrotate to retain log files for 30 days.
- **Service Recovery:** A cron job continuously monitors the Squid service and automatically restarts it when needed.
- **Public IP Auto-Detection:** The script retrieves your server’s public IPv4 address with `curl -4 -s ifconfig.me` for easy setup.
- **Script Exit:** The script ends with an `exit 0`, ensuring that successful execution is clearly indicated.

## Auto Setup with Startup Script

To automatically clone and install this repository, you can use the **startup script** feature provided by cloud platforms during instance creation.

```bash
#!/bin/bash

# Update packages and install Git
apt update -y && apt install -y git

# Move to root directory
cd /root || exit

# Clone the repository
git clone https://github.com/w3labkr/sh-squid-proxy.git

# Enter the directory
cd sh-squid-proxy || exit

# Make the install script executable
chmod +x install.sh

# Run the install script with desired options
./install.sh -t 3128 -u ghost -p '123456' -w "127.0.0.1"
```

## License

This project is licensed under the [MIT License](LICENSE).  
Feel free to use and modify the script as needed.
