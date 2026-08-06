#!/bin/bash
# تثبيت Dark Shield Bot
# 📅 2024-11-15
# 👨‍💻 @a11y11

echo "🛡️ Dark Shield Bot — Installation"
echo "================================="

# تثبيت Lua
if ! command -v lua &> /dev/null; then
    echo "📦 Installing Lua..."
    apt-get update && apt-get install -y lua5.4 luarocks
fi

# تثبيت Redis
if ! command -v redis-server &> /dev/null; then
    echo "📦 Installing Redis..."
    apt-get install -y redis-server
fi

# تثبيت حزم Lua
echo "📦 Installing Lua modules..."
luarocks install lua-resty-redis
luarocks install lua-https
luarocks install dkjson

# تثبيت yt-dlp (اختياري)
if ! command -v yt-dlp &> /dev/null; then
    echo "📦 Installing yt-dlp (optional)..."
    pip3 install yt-dlp
fi

# إنشاء المجلدات
mkdir -p logs data/backups data/redis

# نسخ ملف البيئة
if [ ! -f .env ]; then
    cp env.example .env
    echo "⚠️  Please edit .env and set your BOT_TOKEN"
fi

echo ""
echo "✅ Installation complete!"
echo "📋 Next steps:"
echo "   1. Edit .env and set BOT_TOKEN"
echo "   2. Start Redis: redis-server --daemonize yes"
echo "   3. Start the bot: ./scripts/start.sh"
