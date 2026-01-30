#!/bin/bash
# ==========================================
# Script: UDP ZIVPN OGH-POTATO (FIX KONEK)
# Fitur: Auto-Configure UDP Custom Engine
# ==========================================

# --- Kode Warna ANSI ---
NC='\033[0m'
BOLD='\033[1m'
PURPLE='\033[0;35m'
MAGENTA='\033[1;35m'
RED='\033[0;31m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

# --- Variabel System ---
SERVICE_NAME="udp-custom"
BINARY_URL="https://github.com/fauzanihanipah/udp/raw/main/udp-custom"
BANNER_PATH="/etc/zivpn-banner.txt"
CONFIG_PATH="/etc/udp/config.json"
IP_VPS=$(curl -s ifconfig.me)

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
    
    RAM=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
    UPTIME=$(uptime -p | sed 's/up //')
    echo -e "${CYAN}  IP: $IP_VPS  |  RAM: $RAM  |  UPTIME: $UPTIME${NC}"
    echo ""
}

function first_setup() {
    if [[ ! -f "/usr/bin/udp-custom" ]]; then
        show_header
        echo -e "${YELLOW}Sedang Menginstal Mesin UDP Custom agar bisa Konek...${NC}"
        
        # 1. Download Binary
        wget -q -O /usr/bin/udp-custom "${BINARY_URL}"
        chmod +x /usr/bin/udp-custom

        # 2. Create Banner HTML
        cat <<EOF > $BANNER_PATH
<font color="magenta"><b>=================================</b></font><br>
<font color="cyan"><b>     OGH PREMIUM UDP CUSTOM      </b></font><br>
<font color="white"><b>      Koneksi Berhasil Terhubung  </b></font><br>
<font color="magenta"><b>=================================</b></font>
EOF

        # 3. Setting Port & Service (PENTING: Port 3671)
        cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom OGH
After=network.target

[Service]
User=root
Type=simple
ExecStart=/usr/bin/udp-custom server -exclude 1,22 -auth -banner $BANNER_PATH
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

        # 4. Membuka Port Firewall (UDP & TCP)
        systemctl daemon-reload
        systemctl enable udp-custom
        systemctl start udp-custom
        
        iptables -F
        iptables -A INPUT -p udp --dport 100:65535 -j ACCEPT
        iptables -A INPUT -p tcp --dport 100:65535 -j ACCEPT
        
        echo -e "${GREEN}Instalasi Selesai! Mesin sudah berjalan.${NC}"
        sleep 2
    fi
}

function create_account() {
    show_header
    echo -e "${BLUE}┌───────────────────────────────────────────┐${NC}"
    echo -e "│  ${GREEN}>>> BUAT AKUN ZIVPN BARU <<<${NC}             │"
    echo -e "${BLUE}└───────────────────────────────────────────┘${NC}"
    read -p "  Username : " user
    id "$user" &>/dev/null && { echo -e "${RED}User sudah ada!${NC}"; sleep 2; return; }
    read -p "  Password : " pass
    read -p "  Expired (Hari): " exp
    
    exp_date=$(date -d "$exp days" +"%Y-%m-%d")
    # Membuat user SSH System (Basis Zivpn)
    useradd -e "$exp_date" -s /bin/false -M "$user"
    echo "$user:$pass" | chpasswd
    
    show_header
    echo -e "${GREEN}✅ DETAIL AKUN ZIVPN (AKTIF)${NC}"
    echo -e "${BLUE}=====================================${NC}"
    echo -e "  Host/IP  : $IP_VPS"
    echo -e "  Port     : 3671"
    echo -e "  User     : $user"
    echo -e "  Pass     : $pass"
    echo -e "  Expired  : $exp_date"
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${YELLOW}Gunakan Payload UDP Custom di aplikasi Zivpn${NC}"
    echo ""
    read -n 1 -s -r -p "Tekan [Enter] untuk kembali..."
}

function list_accounts() {
    show_header
    echo -e "${BLUE}┌──────────────────────────────────────────────────┐${NC}"
    printf "│ %-18s %-18s %-10s │\n" "USERNAME" "EXP DATE" "STATUS"
    echo -e "├──────────────────────────────────────────────────┤${NC}"
    while IFS=: read -r u _ _ uid _ _ _; do
        if [ $uid -ge 1000 ]; then
            expire=$(chage -l "$u" | grep "Account expires" | cut -d: -f2)
            printf "│ %-18s %-18s %-10s │\n" "$u" "$expire" "${GREEN}Active${NC}"
        fi
    done < /etc/passwd | grep -v "nobody"
    echo -e "${BLUE}└──────────────────────────────────────────────────┘${NC}"
}

# Inisialisasi
first_setup

# Loop Menu
while true; do
    show_header
    echo -e "  ${BLUE}┌──────────────────────┐  ┌──────────────────────┐${NC}"
    echo -e "  ${BLUE}│${NC} [01] Buat Akun       ${BLUE}│  │${NC} [03] Hapus Akun      ${BLUE}│${NC}"
    echo -e "  ${BLUE}├──────────────────────┤  ├──────────────────────┤${NC}"
    echo -e "  ${BLUE}│${NC} [02] List Akun       ${BLUE}│  │${NC} [04] Ganti Password  ${BLUE}│${NC}"
    echo -e "  ${BLUE}└──────────────────────┘  └──────────────────────┘${NC}"
    echo -e "                ${BLUE}┌──────────────────────┐${NC}"
    echo -e "                ${BLUE}│${NC}    [05] Info Domain  ${BLUE}│${NC}"
    echo -e "                ${BLUE}├──────────────────────┤${NC}"
    echo -e "                ${BLUE}│${NC}    [00] Exit Program ${BLUE}│${NC}"
    echo -e "                ${BLUE}└──────────────────────┘${NC}"
    echo ""
    echo -ne "  ${BOLD}${CYAN}Pilih Opsi: ${NC}"
    read opt
    case $opt in
        1|01) create_account ;;
        2|02) list_accounts; echo ""; read -n 1 -s -r -p "Tekan Enter..." ;;
        3|03) list_accounts; echo -ne "${RED}User: ${NC}"; read u; userdel -f $u; sleep 1 ;;
        4|04) show_header; read -p "User: " u; read -p "Pass Baru: " p; echo "$u:$p" | chpasswd; sleep 1 ;;
        5|05) show_header; echo -e "IP VPS: $IP_VPS"; read -n 1 ;;
        0|00) exit 0 ;;
        *) echo -e "${RED}Input Salah!${NC}"; sleep 1 ;;
    esac
done
