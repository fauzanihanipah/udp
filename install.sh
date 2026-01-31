#!/bin/bash

# Update & Install Dependency
apt update && apt install python3-pip git wget -y
pip3 install python-telegram-bot --break-system-packages

# Ambil IP VPS otomatis
MYIP=$(wget -qO- ipv4.icanhazip.com)

# Buat file bot.py secara otomatis
cat <<EOF > /root/bot.py
import os
import subprocess
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes

TOKEN = "8509037286:AAEMao-IFVx0V1VK2xbDEILMNO7plLuK5hE"
ADMIN_ID = 1358908223  # Ganti dengan ID Telegram kamu

async def buat(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_user.id != ADMIN_ID:
        return
    if len(context.args) < 3:
        await update.message.reply_text("Format: /buat user pass hari")
        return
    
    u, p, d = context.args[0], context.args[1], context.args[2]
    os.system(f"useradd -e \$(date -d '\$d days' +%Y-%m-%d) -s /bin/false \$u")
    os.system(f"echo '\$u:\$p' | chpasswd")
    
    msg = f"✅ Sukses!\nIP: $MYIP\nUser: \$u\nPass: \$p\nExp: \$d Hari"
    await update.message.reply_text(msg)

if __name__ == '__main__':
    app = ApplicationBuilder().token(TOKEN).build()
    app.add_handler(CommandHandler("buat", buat))
    app.run_polling()
EOF

# Buat Service agar Bot jalan terus (Auto Start)
cat <<EOF > /etc/systemd/system/zibot.service
[Unit]
Description=ZiVPN Bot
After=network.target

[Service]
ExecStart=/usr/bin/python3 /root/bot.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Jalankan Bot
systemctl daemon-reload
systemctl enable zibot
systemctl start zibot

echo "Selesai! Bot sekarang aktif."
