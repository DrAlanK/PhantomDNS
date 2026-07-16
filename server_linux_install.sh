#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
BOLD='\033[1m'
NC='\033[0m'

log_header() { echo -e "\n${CYAN}${BOLD}>>> $1${NC}"; }
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[DONE]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

cat << "EOF"
██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗   ███╗
██╔══██╗██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████╗ ████║
██████╔╝███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║
██╔═══╝ ██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║
██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝
EOF

if [[ "${EUID}" -ne 0 ]]; then
  log_error "Run this script as root (sudo)."
fi

INSTALL_DIR="/opt/PhantomDNS"
ACTION="install"

if [[ "${1:-}" == "-u" || "${1:-}" == "--uninstall" ]]; then
  ACTION="uninstall"
fi

if [[ "$ACTION" == "uninstall" ]]; then
  log_header "Uninstalling PhantomDNS Server"
  systemctl stop phantomdns 2>/dev/null || true
  systemctl disable phantomdns >/dev/null 2>&1 || true
  rm -f /etc/systemd/system/phantomdns.service
  systemctl daemon-reload
  rm -rf "$INSTALL_DIR"
  rm -f /etc/sysctl.d/99-phantomdns.conf /etc/security/limits.d/99-phantomdns.conf
  sysctl --system >/dev/null 2>&1 || true
  log_success "PhantomDNS Uninstalled."
  exit 0
fi

log_header "Preparing Environment"
log_info "Installing dependencies..."
if command -v apt-get >/dev/null 2>&1; then
  apt-get update -y >/dev/null
  apt-get install -y lsof net-tools curl iptables git wireguard-tools >/dev/null
elif command -v dnf >/dev/null 2>&1; then
  dnf -y install lsof net-tools curl iptables git wireguard-tools >/dev/null
elif command -v yum >/dev/null 2>&1; then
  yum -y install lsof net-tools curl iptables git wireguard-tools >/dev/null
fi
log_success "System tools are ready."

log_header "Managing Network Ports (Port 53)"
for srv in systemd-resolved dnsmasq bind9 named unbound pdns; do
  if systemctl list-unit-files --type=service --all 2>/dev/null | grep -qx "${srv}.service"; then
    systemctl stop "$srv" 2>/dev/null || true
    systemctl disable "$srv" >/dev/null 2>&1 || true
  fi
done
if command -v fuser >/dev/null 2>&1; then
  fuser -k 53/udp 2>/dev/null || true
  fuser -k 53/tcp 2>/dev/null || true
fi
log_success "Port 53 has been forcefully freed."

log_header "Configuring Firewall (Port 53 UDP/TCP)"
if command -v ufw >/dev/null 2>&1 && ufw status | grep -qw active; then
  ufw allow 53/udp >/dev/null 2>&1 || true
  ufw allow 53/tcp >/dev/null 2>&1 || true
elif command -v iptables >/dev/null 2>&1; then
  iptables -C INPUT -p udp --dport 53 -j ACCEPT 2>/dev/null || iptables -I INPUT -p udp --dport 53 -j ACCEPT
  iptables -C INPUT -p tcp --dport 53 -j ACCEPT 2>/dev/null || iptables -I INPUT -p tcp --dport 53 -j ACCEPT
fi
log_success "Port 53 opened."

log_header "Tuning Kernel & Limits"
cat > /etc/sysctl.d/99-phantomdns.conf <<'EOF'
fs.file-max = 2097152
fs.nr_open = 2097152
net.core.somaxconn = 65535
net.ipv4.udp_mem = 65536 131072 262144
EOF
sysctl --system >/dev/null 2>&1 || true
cat > /etc/security/limits.d/99-phantomdns.conf <<'EOF'
* soft nofile 1048576
* hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
EOF
log_success "Kernel limits configured."

log_header "Deploying Pre-compiled PhantomDNS Core"
if [ ! -d "$INSTALL_DIR" ]; then
  log_info "Downloading files from GitHub directly to $INSTALL_DIR..."
  git clone https://github.com/DrAlanK/PhantomDNS.git "$INSTALL_DIR" >/dev/null 2>&1
else
  log_info "Updating existing installation..."
  cd "$INSTALL_DIR"
  git stash >/dev/null 2>&1 || true
  git pull >/dev/null 2>&1 || true
fi

cd "$INSTALL_DIR"
chmod +x phantomdns-server

# ==========================================
# ⚡ INTERACTIVE CONFIGURATION (FAMILY SCENARIO)
# ==========================================
log_header "Interactive Configuration (Private Tunnel)"
echo -e "${YELLOW}Let's set up your private server endpoint.${NC}"
while true; do
  read -p "Enter your Server Domain or IP (e.g., api.mydomain.com): " SERVER_ADDRESS
  if [[ -n "$SERVER_ADDRESS" ]]; then
    break
  else
    echo -e "${RED}[!] Address cannot be empty. Please try again.${NC}"
  fi
done

log_info "Generating military-grade X25519 Encryption Keys..."
if ! command -v wg >/dev/null 2>&1; then
  log_error "wireguard-tools is missing! Cannot generate keys."
fi
SERVER_PRIV=$(wg genkey)
SERVER_PUB=$(echo "$SERVER_PRIV" | wg pubkey)
log_success "Keys generated successfully."

log_info "Building and saving users.json..."
mkdir -p "$INSTALL_DIR/internal"
cat <<EOF > "$INSTALL_DIR/internal/users.json"
{
  "server_address": "$SERVER_ADDRESS",
  "private_key": "$SERVER_PRIV",
  "public_key": "$SERVER_PUB",
  "mtu": 1300,
  "users": [
    {
      "uuid": "family-private-user-01",
      "status": "active"
    }
  ]
}
EOF
log_success "Configuration saved securely."
# ==========================================

log_info "Creating Systemd service..."
cat <<EOF > /etc/systemd/system/phantomdns.service
[Unit]
Description=PhantomDNS High-Performance Tunnel
After=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/phantomdns-server
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable phantomdns.service >/dev/null 2>&1
systemctl restart phantomdns.service

if systemctl is-active --quiet phantomdns; then
  echo -e "\n${CYAN}======================================================${NC}"
  echo -e " ${GREEN}${BOLD}       INSTALLATION COMPLETED SUCCESSFULLY!${NC}"
  echo -e "${CYAN}======================================================${NC}"
  echo -e "${YELLOW}[+] Server Address :${NC} $SERVER_ADDRESS"
  echo -e "${YELLOW}[+] Public Key     :${NC} $SERVER_PUB"
  echo -e "${YELLOW}[!] Private Key    :${NC} (Saved securely in $INSTALL_DIR/internal/users.json)"
  echo -e "\n${BOLD}Share the Server Address and Public Key with your clients!${NC}\n"
else
  log_error "Service failed to start. Run 'journalctl -u phantomdns -f' for details."
fi