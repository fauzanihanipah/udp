import os
import subprocess
from telegram import Update, ReplyKeyboardMarkup, ReplyKeyboardRemove
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes, MessageHandler, filters

# --- KONFIGURASI ---
TOKEN = "8509037286:AAEMao-IFVx0V1VK2xbDEILMNO7plLuK5hE"
ADMIN_ID = 1358908223  # Ganti dengan ID Telegram kamu
# -------------------

# State untuk percakapan
CHOOSING, GET_USER_PASS = range(2)

# Menu Utama
def main_menu():
    return ReplyKeyboardMarkup([
        ['➕ Buat Akun', '🗑️ Hapus Akun'],
        ['📊 Status VPS', '🔄 Restart ZiVPN']
    ], resize_keyboard=True)

# Menu Pilihan Durasi
def duration_menu():
    return ReplyKeyboardMarkup([
        ['1 Hari (Trial)', '7 Hari'],
        ['30 Hari', '🔙 Batal']
    ], resize_keyboard=True)

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_user.id != ADMIN_ID: return
    await update.message.reply_text("Pilih Menu Admin ZiVPN:", reply_markup=main_menu())

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_user.id != ADMIN_ID: return
    text = update.message.text

    if text == '➕ Buat Akun':
        await update.message.reply_text("Pilih Durasi Akun:", reply_markup=duration_menu())
    
    elif text in ['1 Hari (Trial)', '7 Hari', '30 Hari']:
        # Simpan durasi pilihan ke context
        context.user_data['days'] = text.split()[0]
        await update.message.reply_text(f"Pilihan: {text}\nFormat: `user pass` (pisahkan spasi)", parse_mode='Markdown', reply_markup=ReplyKeyboardRemove())
        return GET_USER_PASS

    elif text == '🗑️ Hapus Akun':
        await update.message.reply_text("Ketik: `/hapus username`")

    elif text == '📊 Status VPS':
        ram = subprocess.getoutput("free -m | awk 'NR==2{printf \"%.2f%%\", $3*100/$2 }'")
        msg = f"📊 **STATUS VPS**\nRAM Usage: {ram}\nIP: {subprocess.getoutput('wget -qO- ipv4.icanhazip.com')}"
        await update.message.reply_text(msg, parse_mode='Markdown')

    elif text == '🔄 Restart ZiVPN':
        os.system("systemctl restart zivpn")
        await update.message.reply_text("✅ Service ZiVPN Berhasil di Restart!")

    elif text == '🔙 Batal':
        await update.message.reply_text("Dibatalkan.", reply_markup=main_menu())

async def process_create(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_user.id != ADMIN_ID: return
    try:
        data = update.message.text.split()
        user, pw = data[0], data[1]
        days = context.user_data.get('days', '1')
        
        # Eksekusi sistem
        os.system(f"useradd -e $(date -d '{days} days' +%Y-%m-%d) -s /bin/false {user}")
        os.system(f"echo '{user}:{pw}' | chpasswd")
        
        ip = subprocess.getoutput("wget -qO- ipv4.icanhazip.com")
        res = (f"✅ **AKUN BERHASIL**\n"
               f"User: `{user}`\nPass: `{pw}`\nExp: {days} Hari\n"
               f"Config: `{ip}:36712@{user}:{pw}`")
        
        await update.message.reply_text(res, parse_mode='Markdown', reply_markup=main_menu())
    except:
        await update.message.reply_text("❌ Gagal! Pastikan format benar: `user pass`", reply_markup=main_menu())
    return ConversationHandler.END

async def hapus_akun(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_user.id != ADMIN_ID: return
    if not context.args: return
    user = context.args[0]
    os.system(f"userdel -f {user}")
    await update.message.reply_text(f"✅ User `{user}` telah dihapus.", parse_mode='Markdown')

if __name__ == '__main__':
    from telegram.ext import ConversationHandler
    app = ApplicationBuilder().token(TOKEN).build()
    
    conv_handler = ConversationHandler(
        entry_points=[MessageHandler(filters.Regex('^(1 Hari \(Trial\)|7 Hari|30 Hari)$'), handle_message)],
        states={GET_USER_PASS: [MessageHandler(filters.TEXT & ~filters.COMMAND, process_create)]},
        fallbacks=[],
    )

    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("hapus", hapus_akun))
    app.add_handler(conv_handler)
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    
    app.run_polling()
