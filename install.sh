#!/bin/bash

# --- KONFIGURASI ---
TOKEN="8509037286:AAEMao-IFVx0V1VK2xbDEILMNO7plLuK5hE"
ADMIN_ID="1358908223"
# -------------------

echo "Mulai membersihkan dan menginstal ulang Bot ZiVPN..."

# 1. Matikan dan Hapus Service Lama
systemctl stop zibot 2>/dev/null
systemctl disable zibot 2>/dev/null
pkill -f bot.py

# 2. Hapus file lama agar tidak bentrok
rm -rf /root/bot.py
rm -rf /etc/systemd/system/zibot.service

# 3. Install/Update Dependency
apt update && apt install python3-pip wget -y
pip3 install python-telegram-bot --upgrade --break-system-packages

# 4. Buat File bot.py Baru (Versi Sempurna)
cat <<EOF > /root/bot.py
import os
import subprocess
from telegram import Update, ReplyKeyboardMarkup, ReplyKeyboardRemove
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes, MessageHandler, filters, ConversationHandler

TOKEN = "$TOKEN"
ADMIN_ID = $ADMIN_ID
GET_USER_PASS = 1

def main_menu():
    return ReplyKeyboardMarkup([['➕ Buat Akun', '🗑️ Hapus Akun'], ['📊 Status VPS', '🔄 Restart ZiVPN']], resize_keyboard=True)

def duration_menu():
    return ReplyKeyboardMarkup([['1 Hari (Trial)', '7 Hari'], ['30 Hari', '🔙 Batal']], resize_keyboard=True)

async def start(update, context):
    if update.effective_user.id != ADMIN_ID: return
    await update.message.reply_text("🛠️ **Panel Admin ZiVPN**", reply_markup=main_menu(), parse_mode='Markdown')

async def handle_menu(update, context):
    if update.effective_user.id != ADMIN_ID: return
    text = update.message.text
    if text == '➕ Buat Akun':
        await update.message.reply_text("Pilih Durasi:", reply_markup=duration_menu())
    elif text in ['1 Hari (Trial)', '7 Hari', '30 Hari']:
        context.user_data['days'] = text.split()[0]
        await update.message.reply_text("Masukkan \`user pass\` (contoh: \`agus 123\`)", reply_markup=ReplyKeyboardRemove(), parse_mode='Markdown')
        return GET_USER_PASS
    elif text == '📊 Status VPS':
        uptime = subprocess.getoutput("uptime -p")
        ip = subprocess.getoutput("wget -qO- ipv4.icanhazip.com")
        await update.message.reply_text(f"📊 **INFO**\nIP: \`{ip}\`\nUp: {uptime}", parse_mode='Markdown')
    elif text == '🔄 Restart ZiVPN':
        os.system("systemctl restart zivpn")
        await update.message.reply_text("✅ Restart Berhasil!")
    return ConversationHandler.END

async def process_create(update, context):
    try:
        u, p = update.message.text.split()
        d = context.user_data.get('days', '1')
        os.system(f"useradd -e \$(date -d '\$d days' +%Y-%m-%d) -s /bin/false \$u")
        os.system(f"echo '\$u:\$p' | chpasswd")
        ip = subprocess.getoutput("wget -qO- ipv4.icanhazip.com")
        await update.message.reply_text(f"✅ **SUKSES**\nUser: \`\$u\`\nPass: \`\$p\`\nExp: \$d Hari\nConfig: \`\$ip:36712@\$u:\$p\`", reply_markup=main_menu(), parse_mode='Markdown')
    except:
        await update.message.reply_text("❌ Gagal! Format: \`user pass\`", reply_markup=main_menu(), parse_mode='Markdown')
    return ConversationHandler.END

async def hapus(update, context):
    if update.effective_user.id == ADMIN_ID and context.args:
        os.system(f"userdel -f {context.args[0]}")
        await update.message.reply_text(f"🗑️ User \`{context.args[0]}\` dihapus.", parse_mode='Markdown')

if __name__ == '__main__':
    app = ApplicationBuilder().token(TOKEN).build()
    conv = ConversationHandler(
        entry_points=[MessageHandler(filters.Regex('^(1 Hari \(Trial\)|7 Hari|30 Hari)$'), handle_menu)],
        states={GET_USER_PASS: [MessageHandler(filters.TEXT & ~filters.COMMAND, process_create)]},
        fallbacks=[MessageHandler(filters.Regex('^🔙 Batal$'), start)],
    )
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("hapus", hapus))
    app.add_handler(conv)
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_menu))
    app.run_polling()
EOF

# 5. Pasang Service Otomatis
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

# 6. Aktivasi
systemctl daemon-reload
systemctl enable zibot
systemctl start zibot

echo "----------------------------------------------"
echo "  BERSIH DAN TERINSTAL! Bot sudah aktif.     "
echo "----------------------------------------------"
