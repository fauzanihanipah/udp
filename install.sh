import os
import subprocess
from telegram import Update, ReplyKeyboardMarkup
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes, MessageHandler, filters

# --- KONFIGURASI ---
TOKEN = "8509037286:AAEMao-IFVx0V1VK2xbDEILMNO7plLuK5hE"
ADMIN_ID = 1358908223  # Ganti dengan ID Telegram kamu
# -------------------

# Menu Tombol Utama
def main_menu_keyboard():
    keyboard = [
        ['➕ Buat Akun Premium', '⏳ Buat Akun Trial'],
        ['🗑️ Hapus Akun', '📊 Status VPS'],
        ['🔄 Restart ZiVPN', '🚪 Keluar']
    ]
    return ReplyKeyboardMarkup(keyboard, resize_keyboard=True)

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_user.id != ADMIN_ID:
        return
    await update.message.reply_text(
        "Selamat Datang di Panel ZiVPN Premium!\nSilakan pilih menu di bawah:",
        reply_markup=main_menu_keyboard()
    )

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_user.id != ADMIN_ID:
        return
    
    text = update.message.text

    if text == '➕ Buat Akun Premium':
        await update.message.reply_text("Format: `/buat user pass hari`", parse_mode='Markdown')
    
    elif text == '⏳ Buat Akun Trial':
        await update.message.reply_text("Format: `/trial user pass` (Otomatis 1 Hari)", parse_mode='Markdown')

    elif text == '📊 Status VPS':
        uptime = subprocess.getoutput("uptime -p")
        cpu = subprocess.getoutput("top -bn1 | grep 'Cpu(s)' | awk '{print $2}'")
        ram = subprocess.getoutput("free -m | awk 'NR==2{printf \"%.2f%%\", $3*100/$2 }'")
        msg = f"📊 **STATUS VPS**\n\n⏱ Uptime: {uptime}\n⚡ CPU Load: {cpu}%\n🧠 RAM Usage: {ram}"
        await update.message.reply_text(msg, parse_mode='Markdown')

    elif text == '🔄 Restart ZiVPN':
        os.system("systemctl restart zivpn")
        await update.message.reply_text("✅ ZiVPN Service telah di-restart!")

async def buat_premium(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_user.id != ADMIN_ID: return
    if len(context.args) < 3:
        await update.message.reply_text("Gunakan: /buat username password hari")
        return
    
    u, p, d = context.args[0], context.args[1], context.args[2]
    os.system(f"useradd -e $(date -d '{d} days' +%Y-%m-%d) -s /bin/false {u}")
    os.system(f"echo '{u}:{p}' | chpasswd")
    
    ip = subprocess.getoutput("wget -qO- ipv4.icanhazip.com")
    res = f"✅ **AKUN PREMIUM AKTIF**\n\nUser: `{u}`\nPass: `{p}`\nExp: {d} Hari\nHost: `{ip}`\nConfig: `{ip}:36712@{u}:{p}`"
    await update.message.reply_text(res, parse_mode='Markdown')

if __name__ == '__main__':
    app = ApplicationBuilder().token(TOKEN).build()
    
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("buat", buat_premium))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    
    print("Bot dengan Menu Tombol aktif...")
    app.run_polling()
