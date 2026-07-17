#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# --- Premium Dark & Gold Aesthetic Colors ---
GOLD='\033[38;2;212;175;55m'
DARK_GREY='\033[38;2;60;64;67m'
WHITE='\033[1;37m'
RED='\033[1;31m'
NC='\033[0m'
BOLD='\033[1m'

log_header() { echo -e "\n${GOLD}${BOLD}❖ $1 ❖${NC}"; }
log_info() { echo -e "${DARK_GREY}[INFO]${NC} ${WHITE}$1${NC}"; }
log_success() { echo -e "${GOLD}[DONE]${NC} ${WHITE}$1${NC}"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

cat << "EOF"
[38;2;212;175;55m
  _____  _                 _                  _____  _   _  _____ 
 |  __ \| |               | |                |  __ \| \ | |/ ____|
 | |__) | |__   __ _ _ __ | |_ ___  _ __ ___ | |  | |  \| | (___  
 |  ___/| '_ \ / _` | '_ \| __/ _ \| '_ ` _ \| |  | | . ` |\___ \ 
 | |    | | | | (_| | | | | || (_) | | | | | | |__| | |\  |____) |
 |_|    |_| |_|\__,_|_| |_|\__\___/|_| |_| |_|_____/|_| \_|_____/ 
[0m
EOF
echo -e "${DARK_GREY}${BOLD}         PhantomDNS Multi-User Core Setup${NC}\n"

if [[ "${EUID}" -ne 0 ]]; then
  log_error "Please run this script as root (sudo)."
fi

INSTALL_DIR="/opt/PhantomDNS"
CONF_DIR="/etc/phantomdns"

log_header "Preparing Server Environment"
log_info "Updating packages and installing dependencies..."
apt-get update -y >/dev/null 2>&1 || yum check-update -y >/dev/null 2>&1
apt-get install -y git curl wget lsof iptables net-tools unzip >/dev/null 2>&1 || yum install -y git curl wget lsof iptables net-tools unzip >/dev/null 2>&1
log_success "System dependencies installed."

log_header "Installing Go Compiler"
if ! command -v go >/dev/null 2>&1; then
    log_info "Downloading and installing Go 1.22..."
    wget -q https://go.dev/dl/go1.22.1.linux-amd64.tar.gz
    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.22.1.linux-amd64.tar.gz
    rm -f go1.22.1.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
    log_success "Go compiler installed successfully."
else
    log_success "Go compiler is already installed."
fi

log_header "Managing Port 53"
systemctl stop systemd-resolved 2>/dev/null || true
systemctl disable systemd-resolved >/dev/null 2>&1 || true
fuser -k 53/udp 2>/dev/null || true
fuser -k 53/tcp 2>/dev/null || true
log_success "Port 53 successfully freed for PhantomDNS."

log_header "Deploying PhantomDNS Core"
if [ ! -d "$INSTALL_DIR" ]; then
  git clone https://github.com/DrAlanK/phantomdns.git "$INSTALL_DIR" >/dev/null 2>&1
else
  cd "$INSTALL_DIR"
  git pull >/dev/null 2>&1 || true
fi

log_info "Compiling the server binary..."
cd "$INSTALL_DIR"
/usr/local/go/bin/go build -o phantomdns-server cmd/server/main.go
chmod +x phantomdns-server
log_success "Compilation finished."

log_header "Setting Up PhantomDNS CLI Manager"
mkdir -p "$CONF_DIR"

# ساخت دستور میانبر سراسری phantom
cat <<EOF > "/usr/local/bin/phantom"
#!/usr/bin/env bash
$INSTALL_DIR/phantomdns-server -users -config $CONF_DIR/server_config.toml
EOF
chmod +x "/usr/local/bin/phantom"

# کانفیگ اولیه سرور در صورت عدم وجود
if [ ! -f "$CONF_DIR/server_config.toml" ]; then
cat <<EOF > "$CONF_DIR/server_config.toml"
PROTOCOL_TYPE = "SOCKS5"
UDP_HOST = "0.0.0.0"
UDP_PORT = 53
USE_EXTERNAL_SOCKS5 = true
FORWARD_IP = "127.0.0.1"
FORWARD_PORT = 1080
LOG_LEVEL = "INFO"
EOF
fi

log_success "Global 'phantom' command created!"

log_header "Systemd Service Setup"
cat <<EOF > /etc/systemd/system/phantomdns.service
[Unit]
Description=PhantomDNS Multi-User Core
After=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/phantomdns-server -config $CONF_DIR/server_config.toml
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable phantomdns.service >/dev/null 2>&1

log_header "Initial Admin Setup"
echo -e "${DARK_GREY}We need to create the first administrative route.${NC}"
/usr/local/bin/phantom

systemctl restart phantomdns.service

echo -e "\n${GOLD}======================================================${NC}"
echo -e " ${BOLD}       PHANTOM DNS INSTALLED SUCCESSFULLY!${NC}"
echo -e "${GOLD}======================================================${NC}"
echo -e "${WHITE}  To manage users anytime, just type: ${GOLD}phantom${NC}"
echo -e "${WHITE}  To check server logs, type: ${GOLD}journalctl -u phantomdns -f${NC}"
echo -e "\n${DARK_GREY}Powered by @DrAlanCH | @DR_A_88${NC}\n"