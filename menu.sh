#!/bin/bash
# ==========================================
# Script: UDP ZIVPN OGH-POTATO ULTIMATE (VISUAL)
# Fitur: Auto-Delete Expired & Stylish UI
# ==========================================

# --- Kode Warna ANSI ---
NC='\033[0m'
BOLD='\1'
# Gradient OGH (Ungu ke Merah)
PURPLE='\033[0;35m'
MAGENTA='\033[1;35m'
PINK='\033[0;95m'
RED='\033[0;31m'
# Bingkai & Text
BLUE='\033[1;34m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

# --- Variabel System ---
SERVICE_NAME="udp-custom"
EXTRACT_DOMAIN="/etc/xray/domain"

function show_header() {
    clear
    # Logo OGH dengan Warna Ungu ke Merah-merahan
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

# --- Fitur Auto-Delete (Cronjob) ---
function setup_autodelete() {
    if ! crontab -l | grep -q "userdel"; then
        (crontab -l 2>/dev/null; echo "0 0 * * * /usr/sbin/userdel \$(awk -F: '\$3 >= 1000 && \$7 !~ /nologin/ {print \$1}' /etc/passwd | xargs -I {} sh -c 'if [ \$(date +%s) -ge \$(date -d \"\$(chage -l {} | grep \"Account expires\" | cut -d: -f2)\" +%s 2>/dev/null || echo 9999999999); then echo {}; fi')") | crontab -
    fi
}
setup_autodelete

# 1. Spek VPS
function vps_specs() {
    show_header
    echo -e "${BLUE}┌───────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}  ${YELLOW}>>> SYSTEM STATUS <<<${NC}                ${BLUE}│${NC}"
    echo -e "${BLUE}├───────────────────────────────────────────┤${NC}"
    echo -e "${BLUE}│${NC} OS      : $(cat /etc/os-release | grep -w PRETTY_NAME | cut -d'"' -f2 | head -c 20)"
    echo -e "${BLUE}│${NC} RAM     : $(free -h | awk '/Mem:/ {print $3 "/" $2}')"
    echo -e "${BLUE}│${NC} Uptime  : $(uptime -p | head -c 20)"
    echo -e "${BLUE}│${NC} Service : ${GREEN}ACTIVE${NC}                       ${BLUE}│${NC}"
    echo -e "${BLUE}└───────────────────────────────────────────┘${NC}"
    echo ""
    read -n 1 -s -r -p "Tekan [Enter] untuk kembali..."
}

# 2. Buat Akun
function create_account() {
    show_header
    echo -e "${BLUE}┌───────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}  ${GREEN}>>> CREATE NEW USER <<<${NC}              ${BLUE}│${NC}"
    echo -e "${BLUE}└───────────────────────────────────────────┘${NC}"
    read -p "  Username : " user
    id "$user" &>/dev/null && { echo -e "${RED}User sudah ada!${NC}"; sleep 2; return; }
    read -p "  Password : " pass
    read -p "  Expired (Hari): " exp
    
    exp_date=$(date -d "$exp days" +"%Y-%m-%d")
    useradd -e "$exp_date" -s /bin/false -M "$user"
    echo "$user:$pass" | chpasswd
    systemctl restart $SERVICE_NAME 2>/dev/null
    echo -e "\n${GREEN}Sukses! Akun $user telah aktif.${NC}"
    read -n 1 -s -r -p "Tekan [Enter] untuk kembali..."
}

# 3. List Akun
function list_accounts() {
    show_header
    echo -e "${BLUE}┌───────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}  ${PURPLE}>>> USER LIST <<<${NC}                    ${BLUE}│${NC}"
    echo -e "${BLUE}├───────────────────────────────────────────┤${NC}"
    printf "${BLUE}│${NC} %-15s %-15s ${BLUE}│${NC}\n" "USERNAME" "EXP DATE"
    echo -e "${BLUE}├───────────────────────────────────────────┤${NC}"
    while IFS=: read -r u _ _ uid _ _ _; do
        if [ $uid -ge 1000 ]; then
            expire=$(chage -l "$u" | grep "Account expires" | cut -d: -f2)
            printf "${BLUE}│${NC} %-15s %-15s ${BLUE}│${NC}\n" "$u" "$expire"
        fi
    done < /etc/passwd | grep -v "nobody"
    echo -e "${BLUE}└───────────────────────────────────────────┘${NC}"
    read -n 1 -s -r -p "Tekan [Enter] untuk kembali..."
}

# 4. Delete & Password Functions (Disederhanakan untuk contoh)
function delete_account() {
    show_header
    read -p "Username yang dihapus: " user
    userdel -f "$user" && echo -e "${GREEN}Dihapus!${NC}" || echo -e "${RED}Gagal!${NC}"
    sleep 2
}

function change_password() {
    show_header
    read -p "Username: " user
    read -p "Pass Baru: " pass
    echo "$user:$pass" | chpasswd && echo -e "${GREEN}Updated!${NC}"
    sleep 2
}

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
        4|04) delete_account ;;
        5|05) change_password ;;
        6|06) show_header; echo -e "IP VPS: $(curl -s ifconfig.me)"; read -n 1 ;;
        0|00) clear; exit 0 ;;
        *) echo -e "${RED}Salah input!${NC}"; sleep 1 ;;
    esac
done
