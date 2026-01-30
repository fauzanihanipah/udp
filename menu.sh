#!/bin/bash
# ==========================================
# Script: UDP ZIVPN OGH-POTATO ULTIMATE
# Fitur: Auto-Install Machine + Management
# ==========================================

# --- Warna & Style ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[1;34m'
PURPLE='\033[0;35m'
MAGENTA='\033[1;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Variabel System ---
SERVICE_NAME="udp-custom"
BINARY_URL="https://github.com/fauzanihanipah/udp/raw/main/udp-custom"
EXTRACT_DOMAIN="/etc/xray/domain"

# --- Fungsi Header ---
function show_header() {
    clear
    echo -e "${BLUE}  __________________________________________________${NC}"
    echo -e "${BLUE} |                                                  |${NC}"
    echo -e " | ${PURPLE}      ____     ${MAGENTA}   ____   ${RED}   _   _  ${BLUE}          |${NC}"
    echo -e " | ${PURPLE}     / __ \    ${MAGENTA}  / ___|  ${RED}  | | | | ${BLUE}          |${NC}"
    echo -e " | ${PURPLE}    | |  | |   ${MAGENTA} | |  _   ${RED}  | |_| | ${BLUE}          |${NC}"
    echo -e " | ${PURPLE}    | |__| |   ${MAGENTA} | |_| |  ${RED}  |  _  | ${BLUE}          |${NC}"
    echo -e " | ${PURPLE}     \____/    ${MAGENTA}  \____|  ${RED}  |_| |_| ${BLUE}          |${NC}"
    echo -e "${BLUE} |                                                  |${NC}"
    echo -e "${BLUE} |${NC}        ${BOLD}${CYAN}POTATO x OGH - ULTIMATE MANAGER${NC}${BLUE}         |${NC}"
    echo -e "${BLUE} |__________________________________________________|${NC}"
    echo ""
}

# --- 1. Fungsi Instalasi (Dijalankan jika belum ada) ---
function first_setup() {
    if [[ ! -f "/usr/bin/udp-custom" ]]; then
        show_header
        echo -e "${YELLOW}Menyiapkan Mesin Zivpn untuk pertama kali...${NC}"
        
        # Download Binary
        echo -e "${BLUE}[1/3]${NC} Downloading UDP Custom Engine..."
        wget -q -O /usr/bin/udp-custom "${BINARY_URL}"
        chmod +x /usr/bin/udp-custom

        # Membuat Service
        echo -e "${BLUE}[2/3]${NC} Starting Zivpn Service..."
        cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom OGH
After=network.target

[Service]
ExecStart=/usr/bin/udp-custom server
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

        systemctl daemon-reload
        systemctl enable udp-custom
        systemctl start udp-custom
        
        # Open Firewall
        echo -e "${BLUE}[3/3]${NC} Opening Firewall Ports..."
        iptables -A INPUT -p udp --dport 1:65535 -j ACCEPT
        iptables -A INPUT -p tcp --dport 1:65535 -j ACCEPT
        
        echo -e "${GREEN}Instalasi Mesin Selesai!${NC}"
        sleep 2
    fi
}

# --- 2. Fitur Auto-Delete (Cronjob) ---
function setup_autodelete() {
    if ! crontab -l 2>/dev/null | grep -q "userdel"; then
        (crontab -l 2>/dev/null; echo "0 0 * * * /usr/sbin/userdel \$(awk -F: '\$3 >= 1000 && \$7 !~ /nologin/ {print \$1}' /etc/passwd | xargs -I {} sh -c 'if [ \$(date +%s) -ge \$(date -d \"\$(chage -l {} | grep \"Account expires\" | cut -d: -f2)\" +%s 2>/dev/null || echo 9999999999); then echo {}; fi')") | crontab -
    fi
}

# --- Fungsi-fungsi Menu ---
function vps_specs() {
    show_header
    echo -e "${BLUE}┌───────────────────────────────────────────┐${NC}"
    echo -e "│  ${YELLOW}>>> SYSTEM STATUS <<<${NC}                │"
    echo -e "├───────────────────────────────────────────┤${NC}"
    echo -e "│ OS      : $(cat /etc/os-release | grep -w PRETTY_NAME | cut -d'"' -f2 | head -c 20)"
    echo -e "│ RAM     : $(free -h | awk '/Mem:/ {print $3 "/" $2}')"
    echo -e "│ Service : $(systemctl is-active udp-custom)${NC}"
    echo -e "${BLUE}└───────────────────────────────────────────┘${NC}"
    read -n 1 -s -r -p "Tekan [Enter] untuk kembali..."
}

function create_account() {
    show_header
    echo -e "${GREEN}>>> CREATE NEW USER <<<${NC}"
    read -p "  Username : " user
    id "$user" &>/dev/null && { echo -e "${RED}User sudah ada!${NC}"; sleep 2; return; }
    read -p "  Password : " pass
    read -p "  Expired (Hari): " exp
    exp_date=$(date -d "$exp days" +"%Y-%m-%d")
    useradd -e "$exp_date" -s /bin/false -M "$user"
    echo "$user:$pass" | chpasswd
    echo -e "\n${GREEN}Akun $user Berhasil Dibuat!${NC}"
    read -n 1 -s -r -p "Tekan [Enter] untuk kembali..."
}

function list_accounts() {
    show_header
    echo -e "${BLUE}┌───────────────────────────────────────────┐${NC}"
    printf "│ %-15s %-15s │\n" "USERNAME" "EXP DATE"
    echo -e "├───────────────────────────────────────────┤${NC}"
    while IFS=: read -r u _ _ uid _ _ _; do
        if [ $uid -ge 1000 ]; then
            expire=$(chage -l "$u" | grep "Account expires" | cut -d: -f2)
            printf "│ %-15s %-15s │\n" "$u" "$expire"
        fi
    done < /etc/passwd | grep -v "nobody"
    echo -e "${BLUE}└───────────────────────────────────────────┘${NC}"
    read -n 1 -s -r -p "Tekan [Enter] untuk kembali..."
}

# --- Menjalankan Inisialisasi ---
first_setup
setup_autodelete

# --- Loop Menu Utama ---
while true; do
    show_header
    echo -e "  ${BLUE}┌──────────────────────┐  ┌──────────────────────┐${NC}"
    echo -e "  ${BLUE}│${NC} [01] Spec VPS        ${BLUE}│  │${NC} [04] Hapus Akun      ${BLUE}│${NC}"
    echo -e "  ${BLUE}├──────────────────────┤  ├──────────────────────┤${NC}"
    echo -e "  ${BLUE}│${NC} [02] Buat Akun       ${BLUE}│  │${NC} [05] Ganti Password  ${BLUE}│${NC}"
    echo -e "  ${BLUE}├──────────────────────┤  ├──────────────────────┤${NC}"
    echo -e "  ${BLUE}│${NC} [03] List Akun       ${BLUE}│  │${NC} [06] Info Domain     ${BLUE}│${NC}"
    echo -e "  ${BLUE}└──────────────────────┘  └──────────────────────┘${NC}"
    echo -e "                ${BLUE}┌──────────────────────┐${NC}"
    echo -e "                ${BLUE}│${NC}    [00] Exit Program ${BLUE}│${NC}"
    echo -e "                ${BLUE}└──────────────────────┘${NC}"
    echo ""
    echo -ne "  ${BOLD}${CYAN}Pilih Opsi: ${NC}"
    read opt
    case $opt in
        1|01) vps_specs ;;
        2|02) create_account ;;
        3|03) list_accounts ;;
        4|04) show_header; read -p "User: " u; userdel -f $u; sleep 1 ;;
        5|05) show_header; read -p "User: " u; read -p "Pass: " p; echo "$u:$p" | chpasswd; sleep 1 ;;
        6|06) show_header; echo -e "IP VPS: $(curl -s ifconfig.me)"; read -n 1 ;;
        0|00) exit 0 ;;
        *) echo -e "${RED}Salah input!${NC}"; sleep 1 ;;
    esac
done
