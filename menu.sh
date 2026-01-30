#!/bin/bash
# ==========================================
# Script: ZIVPN MANAGER (AMD64 VERSION)
# Target: KHUSUS APLIKASI ZIVPN (BUKAN HTTP CUSTOM)
# ==========================================

# --- Kode Warna ---
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
BINARY_NAME="udp-zivpn-linux-amd64"
BINARY_URL="https://github.com/fauzanihanipah/udp/raw/main/${BINARY_NAME}"
BINARY_PATH="/usr/bin/${BINARY_NAME}"
BANNER_PATH="/etc/zivpn-banner.txt"
IP_VPS=$(curl -s ifconfig.me)

# Mencari Domain VPS
if [ -f "/etc/xray/domain" ]; then
    DOMAIN=$(cat /etc/xray/domain)
elif [ -f "/etc/v2ray/domain" ]; then
    DOMAIN=$(cat /etc/v2ray/domain)
else
    DOMAIN="No-Domain"
fi

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
    echo -e "${BLUE} |${NC}        ${BOLD}${CYAN}POTATO x OGH - ZIVPN AMD64 MGMT${NC}${BLUE}         |${NC}"
    echo -e "${BLUE} |__________________________________________________|${NC}"
    
    RAM=$(free -h | awk '/Mem:/ {print $3 "/" $2}')
    UPTIME=$(uptime -p | sed 's/up //')
    echo -e "${CYAN}  HOST: $DOMAIN  |  IP: $IP_VPS${NC}"
    echo -e "${CYAN}  RAM: $RAM  |  UPTIME: $UPTIME${NC}"
    echo ""
}

function first_setup() {
    if [[ ! -f "$BINARY_PATH" ]]; then
        show_header
        echo -e "${YELLOW}Mengonfigurasi Mesin Zivpn untuk Pertama Kali...${NC}"
        
        # 1. Download Binary (AMD64)
        wget -q -O "$BINARY_PATH" "${BINARY_URL}"
        chmod +x "$BINARY_PATH"

        # 2. Banner HTML (Khusus untuk Log Zivpn App)
        cat <<EOF > $BANNER_PATH
<br><font color="magenta"><b>=================================</b></font><br>
<font color="cyan"><b>      OGH PREMIUM ZIVPN APP      </b></font><br>
<font color="white"><b>      STATUS: AKTIF & TERHUBUNG   </b></font><br>
<font color="magenta"><b>=================================</b></font><br>
EOF

        # 3. Create Service Systemd (Parameter Khusus agar Zivpn Konek)
        cat <<EOF > /etc/systemd/system/zivpn.service
[Unit]
Description=Zivpn UDP Engine
After=network.target

[Service]
User=root
Type=simple
# -auth: Penting agar mengecek user SSH
# -exclude: Menghindari port sistem agar tidak error
ExecStart=$BINARY_PATH server -exclude 1,22,80,443 -auth -banner $BANNER_PATH
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

        # 4. Aktifkan Service & Buka Port
        systemctl daemon-reload
        systemctl enable zivpn
        systemctl restart zivpn
        
        # Membersihkan firewall dan membuka port UDP secara total
        iptables -F
        iptables -t nat -F
        iptables -A INPUT -p udp --dport 100:65535 -j ACCEPT
        iptables -A INPUT -p tcp --dport 100:65535 -j ACCEPT
        
        echo -e "${GREEN}Sukses! VPS Siap Digunakan untuk Aplikasi Zivpn.${NC}"
        sleep 2
    fi
}

function create_account() {
    show_header
    echo -e "${BLUE}┌───────────────────────────────────────────┐${NC}"
    echo -e "│  ${GREEN}>>> BUAT AKUN ZIVPN BARU <<<${NC}             │"
    echo -e "${BLUE}└───────────────────────────────────────────┘${NC}"
    read -p "  Username : " user
    [[ -z "$user" ]] && return
    id "$user" &>/dev/null && { echo -e "${RED}User sudah ada!${NC}"; sleep 2; return; }
    read -p "  Password : " pass
    read -p "  Expired (Hari): " exp
    
    exp_date=$(date -d "$exp days" +"%Y-%m-%d")
    # Zivpn membaca user sistem. /bin/false agar tidak bisa login terminal
    useradd -e "$exp_date" -s /bin/false -M "$user"
    echo "$user:$pass" | chpasswd
    
    show_header
    echo -e "${GREEN}✅ DATA AKUN APLIKASI ZIVPN${NC}"
    echo -e "${BLUE}=====================================${NC}"
    echo -e "  📌 Host/Domain : $DOMAIN"
    echo -e "  📌 IP VPS      : $IP_VPS"
    echo -e "  📌 Port        : 3671"
    echo -e "  📌 User        : $user"
    echo -e "  📌 Pass        : $pass"
    echo -e "  📌 Expired     : $exp_date"
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${YELLOW}Gunakan Mode 'UDP Custom' di Zivpn App${NC}"
    echo ""
    read -n 1 -s -r -p "Tekan [Enter] untuk kembali..."
}

# Jalankan Setup
first_setup

# Loop Menu Utama
while true; do
    show_header
    echo -e "  ${BLUE}┌──────────────────────┐  ┌──────────────────────┐${NC}"
    echo -e "  ${BLUE}│${NC} [01] Buat Akun       ${BLUE}│  │${NC} [03] Hapus Akun      ${BLUE}│${NC}"
    echo -e "  ${BLUE}├──────────────────────┤  ├──────────────────────┤${NC}"
    echo -e "  ${BLUE}│${NC} [02] List Akun       ${BLUE}│  │${NC} [04] Ganti Password  ${BLUE}│${NC}"
    echo -e "  ${BLUE}└──────────────────────┘  └──────────────────────┘${NC}"
    echo -e "                ${BLUE}┌──────────────────────┐${NC}"
    echo -e "                ${BLUE}│${NC}    [00] Keluar       ${BLUE}│${NC}"
    echo -e "                ${BLUE}└──────────────────────┘${NC}"
    echo ""
    echo -ne "  ${BOLD}${CYAN}Pilih Menu: ${NC}"
    read opt
    case $opt in
        1|01) create_account ;;
        2|02) 
            show_header
            echo -e "${BLUE}┌───────────────────────────────────────────┐${NC}"
            printf "│ %-15s %-15s │\n" "USER" "EXP"
            echo -e "├───────────────────────────────────────────┤${NC}"
            while IFS=: read -r u _ _ uid _ _ _; do
                [[ $uid -ge 1000 ]] && printf "│ %-15s %-15s │\n" "$u" "$(chage -l $u | grep 'expires' | cut -d: -f2)"
            done < /etc/passwd | grep -v "nobody"
            echo -e "${BLUE}└───────────────────────────────────────────┘${NC}"
            read -n 1 -p "Enter..." ;;
        3|03) 
            show_header
            read -p "User yang dihapus: " u
            if id "$u" &>/dev/null; then userdel -f $u && echo "Sukses"; else echo "User tidak ada"; fi
            sleep 1 ;;
        4|04) show_header; read -p "User: " u; read -p "Pass Baru: " p; echo "$u:$p" | chpasswd; echo "Berhasil!"; sleep 1 ;;
        0|00) exit 0 ;;
        *) sleep 1 ;;
    esac
done
