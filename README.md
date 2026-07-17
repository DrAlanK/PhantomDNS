# 👻 PhantomDNS

**Advanced Multi-User Stealth DNS Tunneling & DPI Bypass System**

PhantomDNS is a high-performance, stealth-focused DNS tunneling proxy written in Go. It encapsulates your traffic inside standard DNS requests, dynamically encrypts payloads, and evades Deep Packet Inspection (DPI) systems.

## 🏆 Credits & Acknowledgments

- **Original Core Engine:** Deepest respect and full credit for the foundational architecture of this engine goes to the original master, **[masterking32 / MasterDnsVPN](https://github.com/masterking32/MasterDnsVPN)**.
- **PhantomDNS Fork:** Forked, aggressively optimized, heavily customized (Ghost Mode, X25519 Encryption, Active Chaffing), and maintained by **[Dr. A (DrAlanK)](https://github.com/DrAlanK)**.

## ✨ Key Features
*   **Stealth Gatekeeper:** Drops unauthorized probes silently, preventing scanners from detecting the VPN tunnel.
*   **Multi-User Architecture:** Manage multiple domains and passwords securely without restarting the server.
*   **Auto-MTU Discovery:** Dynamically probes and finds the optimal packet size for your network environment.
*   **Dynamic Codec Injection:** Secures traffic using ChaCha20/XOR without the hassle of public/private key exchanges.
*   **Built-in CLI Manager:** Manage server configurations and user access easily via the `phantom` terminal command.

---

## 🚀 Quick Server Installation (Linux VPS)
To deploy the PhantomDNS server on your VPS, simply run the following one-liner as `root`. The script will install Go, compile the core, setup the firewall, and create a systemd service.

```bash
bash <(curl -sSL [https://raw.githubusercontent.com/DrAlanK/phantomdns/main/server_linux_install.sh](https://raw.githubusercontent.com/DrAlanK/phantomdns/main/server_linux_install.sh))
```
*(Make sure to upload your installer script as `server_linux_install.sh` in the root of this repo).*

**Server Management:**
After installation, simply type `phantom` in your terminal to open the interactive user management CLI.

---

## 🧪 End-to-End (E2E) Local Testing
You can test the entire tunneling process locally (e.g., in GitHub Codespaces) without needing a remote VPS. All required configuration files are safely stored in the `tests/e2e/` directory.

### Step 1: Start the Phantom Server
Open a terminal and run the server using the test configuration:
```bash
go run cmd/server/main.go -config tests/e2e/server_test.toml
```

### Step 2: Start the Phantom Client
Open a second terminal tab and start the client:
```bash
go run cmd/client/main.go -config tests/e2e/client_test.toml
```
*(Wait a few seconds for the Auto-MTU negotiation to pass and the local SOCKS5 port 10887 to open).*

### Step 3: Route Traffic Through the Tunnel
Open a third terminal tab and route a request through the client's local SOCKS5 proxy:
```bash
curl -v -x socks5h://127.0.0.1:10887 [http://google.com](http://google.com)
```
*If everything is configured correctly, the request will be encrypted, sent over UDP/5353, decrypted by the server, and you will see Google's response!*

---
**Powered by @DrAlanCH | @DR_A_88**