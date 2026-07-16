# PhantomDNS 👻

A high-performance, DPI-bypassing tunneling protocol designed for extreme speed and ultimate stealth. Built upon a powerful core, customized to evade intelligent firewalls while maintaining an ultra-low footprint.

---

## 🏆 Credits & Acknowledgments

- **Original Core Engine:** Deepest respect and full credit for the foundational architecture of this engine goes to the original master, **[masterking32 / MasterDnsVPN](https://github.com/masterking32/MasterDnsVPN)**.
- **PhantomDNS Fork:** Forked, aggressively optimized, heavily customized (Ghost Mode, X25519 Encryption, Active Chaffing), and maintained by **[Dr. A (DrAlanK)](https://github.com/DrAlanK)**.

---

## 🚀 Key Features

- ⚡ **Turbocharged Core** – Powered by high-speed compression algorithms (LZ4/ZSTD) ensuring minimal overhead even under heavy load.
- 👻 **Ghost Mode (DPI Evasion)** – Native 0x20 case-randomization with intelligent SNI/subdomain obfuscation.
- 🛰️ **Active Chaffing** – Sends fake `PONG` packets to keep UDP ports active and blend into normal traffic.
- 🔐 **Military-Grade Encryption** – X25519 (ECDH) key exchange with ChaCha20 symmetric encryption.

---

## 📋 Prerequisites

Before installing, make sure your Linux server has **Git** and **Go (Golang)** installed.

For Ubuntu / Debian:

```bash
sudo apt update
sudo apt install git golang -y
```

---

## ⚙️ Configuration

Before running the installer, configure your users and routes.

Edit:

```text
internal/users.json
```

Set your:

- Domain
- User passwords
- MTU limits
- Routes

---

## ⚡ Installation (Build from Source)

Clone the repository and run the installer.

```bash
# 1. Clone the repository
git clone https://github.com/DrAlanK/PhantomDNS.git

# 2. Enter the project directory
cd PhantomDNS

# 3. Make the installer executable
chmod +x server_linux_install.sh

# 4. Run the installer as root
sudo ./server_linux_install.sh
```

The installer will automatically:

- Free Port 53
- Configure firewall rules
- Apply optimized kernel (`sysctl`) settings
- Build the Go binaries
- Install the systemd service
- Start PhantomDNS

---

## 🛠️ Service Management

### Check service status

```bash
sudo systemctl status phantomdns
```

### View live logs

```bash
sudo journalctl -u phantomdns -f
```

### Restart the service

```bash
sudo systemctl restart phantomdns
```

### Stop the service

```bash
sudo systemctl stop phantomdns
```

---

## 🗑️ Uninstallation

To completely remove PhantomDNS from your server:

```bash
sudo ./server_linux_install.sh -u
```

This will remove:

- PhantomDNS service
- Installed binaries
- Systemd service
- Applied kernel tuning
- Firewall configuration

---

## 📄 License

This project is based on the original **MasterDnsVPN** project and contains substantial modifications and additional features developed for **PhantomDNS**.

Please respect the original author's work and retain proper attribution when redistributing or modifying this project.