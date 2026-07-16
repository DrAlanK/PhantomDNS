# PhantomDNS 👻

A high-performance, DPI-bypassing tunneling protocol designed for extreme speed and ultimate stealth. Built upon a powerful core, customized to evade intelligent firewalls while maintaining an ultra-low footprint.

### 🏆 Credits & Acknowledgments

* **Original Core Engine:** Deepest respect and full credit for the foundational architecture of this engine goes to the original master, **[masterking32 / MasterDnsVPN](https://github.com/masterking32/MasterDnsVPN)**.
* **PhantomDNS Fork:** Forked, aggressively optimized, heavily customized (added Ghost Mode, X25519 Encryption, Active Chaffing), and maintained by **[Dr. A (DrAlanK)](https://github.com/DrAlanK)**.

---

### 🚀 Key Features

* **Turbocharged Core**: Powered by high-speed compression algorithms (LZ4/ZSTD) ensuring zero bottleneck even under massive load.
* **Ghost Mode (DPI Evasion)**: Native 0x20 case-randomization mimicking and smart SNI/subdomain noise filters (Entropy Sanitizer).
* **Active Chaffing**: Smart heartbeat system that fires fake `PONG` packets to keep UDP ports permanently alive and undetected.
* **Military-Grade Encryption**: Secured with X25519 (Elliptic Curve Diffie-Hellman) Asymmetric Key Exchange and ChaCha20 symmetric ciphers.

### 📋 Prerequisites

Before installing, ensure your Linux server has `git` and `go` (Golang) installed. 
For Ubuntu/Debian:
```bash
sudo apt update
sudo apt install git golang -y
⚙️ Configuration
Before running the installer, configure your routes and users.
Edit the JSON configuration file located at internal/users.json (or your main config file) to set up your domain, passwords, and MTU limits.

⚡ Installation (Build from Source)
Clone the repository and run the automated installation script. This script will forcefully free Port 53, configure firewall rules, apply ultimate kernel tuning (sysctl), compile the Go source code, and set up a systemd background service.

Bash
# 1. Clone the repository
git clone [https://github.com/DrAlanK/PhantomDNS.git](https://github.com/DrAlanK/PhantomDNS.git)
cd PhantomDNS

# 2. Make the installer executable
chmod +x server_linux_install.sh

# 3. Run the installer as root
sudo ./server_linux_install.sh
🛠️ Service Management
Once installed, PhantomDNS runs automatically in the background. Use the following commands to manage the server:

Check Service Status:

Bash
sudo systemctl status phantomdns
View Live Server Logs:

Bash
sudo journalctl -u phantomdns -f
Restart the Server (Use this after changing configs):

Bash
sudo systemctl restart phantomdns
Stop the Server:

Bash
sudo systemctl stop phantomdns
🗑️ Uninstallation
To completely remove the service, binaries, and kernel limits from your system, simply run the installer with the -u or --uninstall flag:

Bash
sudo ./server_linux_install.sh -u