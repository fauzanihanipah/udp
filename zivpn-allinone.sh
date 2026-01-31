#!/bin/bash

### CONFIG ###
UDP_PORT=7300
DROPBEAR_PORT=143
CONFIG_DIR="/root/zivpn-configs"
MENU_PATH="/usr/bin/menu-zivpn"

mkdir -p $CONFIG_DIR

# WARNA
G='\033[0;32m'
R='\033[0;31m'
Y='\033[1;33m'
C='\033[0;36m'
N='\033[0m'

install_all() {
clear
echo -e "${C}=== UDP OGH + ZiVPN INSTALLER (POTATO) ===${N}"

apt update -y >/dev/null 2>&1
apt install -y curl wget dropbear unzip lsb-release >/dev/null 2>&1

systemctl enable ssh dropbear
sed -i 's/NO_START=1/NO_START=0/' /etc/default/dropbear
sed -i "s/DROPBEAR_PORT=.*/DROPBEAR_PORT=$DROPBEAR_PORT/" /etc/default/dropbear
systemctl restart dropbear

# BADVPN UDP (opsional)
wget -q -O /usr/bin/badvpn-udpgw \
https://github.com/ambrop72/badvpn/releases/download/1.999.130/badvpn-udpgw
chmod +x /usr/bin/badvpn-udpgw

cat > /etc/systemd/system/badvpn.service <<EOF
[Unit]
Description=BadVPN UDPGW
After=network.target
[Service]
ExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:${UDP_PORT}
Restart=always
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable badvpn
systemctl start badvpn

# MENU UTAMA
cat > ${MENU_PATH} <<'EOF'
#!/bin/bash
clear

G='\033[0;32m'; R='\033[0;31m'; Y='\033[1;33m'; C='\033[0;36m'; N='\033[0m'
CONFIG_DIR="/root/zivpn-configs"

echo -e "${C}"
cat << "LOGO"
██╗   ██╗██████╗ ██████╗      ██████╗  ██████╗ ██╗  ██╗
██║   ██║██╔══██╗██╔══██╗    ██╔═══██╗██╔════╝ ██║  ██║
██║   ██║██████╔╝██████╔╝    ██║   ██║██║  ███╗███████║
██║   ██║██╔═══╝ ██╔═══╝     ██║   ██║██║   ██║██╔══██║
╚██████╔╝██║     ██║         ╚██████╔╝╚██████╔╝██║  ██║
 ╚═════╝ ╚═╝     ╚═╝          ╚═════╝  ╚═════╝ ╚═╝  ╚═╝
LOGO
echo -e "${N}"

echo -e "${Y}UDP OGH + ZiVPN MENU${N}"
echo ""
echo "1) Buat Akun Premium"
echo "2) Buat Akun Trial"
echo "3) Hapus Akun"
echo "4) List Akun"
echo "5) Hapus Akun Expired"
echo "6) Restart Service"
echo "7) Generate / Update Config UDP ZiVPN"
echo "8) Install UDP‑ZiVPN Server (Official GitHub)"
echo "0) Keluar"
echo ""
read -p "Pilih: " p

case $p in
1)
read -p "Username : " u
read -p "Password : " pw
read -p "Aktif (hari) : " d
exp=$(date -d "+$d days" +"%Y-%m-%d")
useradd -M $u
echo "$u:$pw" | chpasswd
chage -E $exp $u
clear
echo -e "${G}AKUN BERHASIL DIBUAT${N}"
echo "User    : $u"; echo "Pass    : $pw"; echo "Expired : $exp"
;;

2)
u=trial$(date +%H%M%S)
pw=123
exp=$(date -d "+1 day" +"%Y-%m-%d")
useradd -M $u
echo "$u:$pw" | chpasswd
chage -E $exp $u
clear
echo -e "${G}AKUN TRIAL${N}"
echo "User    : $u"; echo "Pass    : $pw"; echo "Expired : $exp"
;;

3)
echo -e "${Y}DAFTAR AKUN:${N}"
cut -d: -f1 /etc/passwd | grep -E '^[a-z]'
echo ""
read -p "Username yang akan dihapus: " u
echo -e "${R}Hapus akun: $u ? (y/n)${N}"
read c
if [[ $c == "y" ]]; then userdel -r $u; echo -e "${G}Akun $u berhasil dihapus${N}"; else echo "Dibatalkan"; fi
;;

4)
echo -e "${C}LIST AKUN VPN${N}"
printf "%-15s %-15s\n" "USERNAME" "EXPIRED"
for u in $(cut -d: -f1 /etc/passwd | grep -E '^[a-z]'); do
  exp=$(chage -l $u 2>/dev/null | grep "Account expires" | cut -d: -f2)
  echo "$u | $exp"
done
;;

5)
for u in $(cut -d: -f1 /etc/passwd | grep -E '^[a-z]'); do
  exp=$(chage -l $u | grep "Account expires" | cut -d: -f2)
  if [[ "$exp" != " never" && "$exp" < "$(date)" ]]; then userdel -r $u; fi
done
echo -e "${G}Akun expired dibersihkan${N}"
;;

6)
systemctl restart ssh dropbear badvpn
echo -e "${G}Service direstart${N}"
;;

7)
mkdir -p $CONFIG_DIR
echo -e "${Y}ZIVPN UDP CONFIG GENERATOR${N}"
read -p "Username ZiVPN : " zu
read -p "Password ZiVPN : " zp
read -p "Server (default: bug.com) : " zs
zs=${zs:-bug.com}
FILE="$CONFIG_DIR/$zu.conf"
echo "Username=$zu" > $FILE
echo "Password=$zp" >> $FILE
echo "Server=$zs" >> $FILE
echo "Port=7300" >> $FILE
echo "Mode=UDP" >> $FILE
echo "Payload=GET / HTTP/1.1[crlf]Host: $zs[crlf][crlf]" >> $FILE
echo -e "${G}Config tersimpan di $FILE${N}"
read -p "Tekan ENTER untuk kembali..."
;;

8)
echo -e "${Y}Install UDP-ZiVPN Server (Official GitHub)${N}"
read -p "Install untuk AMD64? (y/n) : " a
if [[ $a == "y" ]]; then
  wget -q -O zi.sh https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/zi.sh
  chmod +x zi.sh
  bash zi.sh
else
  wget -q -O zi2.sh https://raw.githubusercontent.com/zahidbd2/udp-zivpn/main/zi2.sh
  chmod +x zi2.sh
  bash zi2.sh
fi
read -p "Tekan ENTER untuk kembali..."
;;

0)
exit
;;
*)
echo "Pilihan tidak valid"
;;
esac
EOF

chmod +x ${MENU_PATH}
grep -q "menu-zivpn" /root/.bashrc || echo "menu-zivpn" >> /root/.bashrc

echo -e "${G}INSTALL SELESAI, VPS AKAN REBOOT${N}"
sleep 3
reboot
}

# RUN
if [ ! -f "$MENU_PATH" ]; then
  install_all
else
  menu-zivpn
fi
