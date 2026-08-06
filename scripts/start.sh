#!/bin/bash
# ============================================================
# START.SH
# ============================================================
# 📅 التاريخ: 2024-11-15
# 👨‍💻 المبرمج والمطور: @a11y11
# 📖 قناة الشروحات والتحديثات: @alaxla
# ============================================================

echo "╔══════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║   🚀 Starting Dark Shield Bot...                        ║"
echo "║   📅 التاريخ: 2024-11-15                                ║"
echo "║   👨‍💻 المبرمج والمطور: @a11y11                           ║"
echo "║   📖 قناة الشروحات والتحديثات: @alaxla                  ║"
echo "║                                                          ║"
echo "╚══════════════════════════════════════════════════════════╝"

cd "$(dirname "$0")/.."

# التأكد من Redis
if ! pgrep -x "redis-server" > /dev/null; then
    echo "🔄 Starting Redis..."
    redis-server --daemonize yes
fi

# تشغيل البوت
if command -v lua5.4 &> /dev/null; then
    lua5.4 src/Dark.lua
elif command -v lua &> /dev/null; then
    lua src/Dark.lua
else
    echo "❌ Lua not found!"
    exit 1
fi