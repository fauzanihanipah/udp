#!/bin/bash
# ==========================================
# Script: UDP ZIVPN OGH-POTATO ULTIMATE
# Powered by: OGH Team x Potato Logic
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

# --- Fungsi Header (Logo OGH Gradient) ---
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

# --- Fungsi Instalasi Mesin & Banner ---
function first_setup() {
    if [[ ! -f "/usr/bin/udp-custom" ]]; then
        show_header
        echo -e "${YELLOW}Menyiapkan Mesin Zivpn untuk pertama kali...${NC}"
        
        # 1. Download Binary
        echo -e "${BLUE}[1/4]${NC} Downloading UDP Custom Engine..."
        wget -q -O /usr/bin/udp-custom "${BINARY_URL}"
        chmod +x /usr/bin/udp-custom

        # 2. Membuat Banner HTML untuk Aplikasi HP
        echo -e "${BLUE}[2/4]${NC} Creating Welcome Banner..."
        cat <<EOF > $BANNER_PATH
<font color="magenta"><b>=================================</b></font><br>
<font color="cyan"><b>     WELCOME TO PREMIUM SERVER   </b></font><br>
<font color="white"><b>         OGH x POTATO EDITION    </b></font><br>
<font color="magenta"><b>=================================</b></font><br>
<font color="yellow"><b> [+] Protokol: UDP Custom (Zivpn)</b></font><br>
<font color="green"><b> [+] Status  : Online & High Speed</b></font><br>
<font color="red"><b> [+] Limit   : No Torrent / No DDOS</b></font><br>
<font color="magenta"><b>=================================</b></font>
EOF

        # 3. Membuat Service Systemd
        echo -e "${BLUE}[3/4]${NC} Starting Zivpn Service..."
        cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom OGH
After=network.target

[Service]
ExecStart=/usr/bin/udp-custom server -exclude 1,2 -banner $BANNER_PATH
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

        systemctl daemon-reload
        systemctl enable udp-custom
        systemctl start udp-custom
        
        # 4. Open Firewall
        echo -e "${BLUE}[4/4]${NC} Opening Firewall Ports..."
        iptables -A INPUT -p udp --dport 1:65535 -j ACCEPT
        iptables -A INPUT -p tcp --dport 1:65535 -j ACCEPT
        
        # Setup Auto-Delete Cron
        (crontab -l 2>/dev/null; echo "0 0 * * * /usr/sbin/userdel \$(awk -F: '\$3 >= 1000 && \$7 !~ /nologin/ {print \$1}' /etc/passwd | xargs -I {} sh -c 'if [ \$(date +%s) -ge \$(date -d \"\$(chage -l {} | grep \"Account expires\" | cut -d: -f2)\" +%s 2>/dev/null || echo 9999999999); then echo {}; fi')") | crontab -

        echo -e "${GREEN}Instalasi Selesai! Silakan buat akun.${NC}"
        sleep 2
    fi
}

# --- Fungsi Menu ---
function create_account() {
    show_header
    echo -e "${BLUE}┌───────────────────────────────────────────┐${NC}"
    echo -e "│  ${GREEN}>>> CREATE NEW USER <<<${NC}              │"
    echo -e "${BLUE}└───────────────────────────────────────────┘${NC}"
    read -p "  Username : " user
    id "$user" &>/dev/null && { echo -e "${RED}User sudah ada!${NC}"; sleep 2; return; }
    read -p "  Password : " pass
    read -p "  Expired (Hari): " exp
    exp_date=$(date -d "$exp days" +"%Y-%m-%d")
    useradd -e "$exp_date" -s /bin/false -M "$user"
    echo "$user:$pass" | chpasswd
    echo -e "\n${GREEN}Sukses! Akun $user aktif sampai $exp_date${NC}"
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
    read -n 1 -s -r -p "Tekan [Enter] untuk kembali..."
}

# --- Main Logic ---
first_setup

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
        1|01) show_header; free -h; uptime -p; read -n 1 ;;
        2|02) create_account ;;
        3|03) list_accounts ;;
        4|04) show_header; read -p "Username: " u; userdel -f $u && echo "Dihapus"; sleep 1 ;;
        5|05) show_header; read -p "User: " u; read -p "Pass Baru: " p; echo "$u:$p" | chpasswd; echo "Update!"; sleep 1 ;;
        6|06) show_header; curl -s ifconfig.me; echo ""; read -n 1 ;;
        0|00) exit 0 ;;
        *) echo -e "${RED}Salah input!${NC}"; sleep 1 ;;
    esac
done
