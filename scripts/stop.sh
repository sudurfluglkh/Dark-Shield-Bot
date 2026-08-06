#!/bin/bash
# إيقاف Dark Shield Bot
# 📅 2024-11-15
# 👨‍💻 @a11y11

PID_FILE="./dark-shield.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    echo "🛑 Stopping Dark Shield Bot (PID: $PID)..."
    kill "$PID" 2>/dev/null
    rm -f "$PID_FILE"
    echo "✅ Bot stopped."
else
    echo "ℹ️  Bot is not running."
    # محاولة قتل أي عملية lua
    pkill -f "lua.*Dark.lua" 2>/dev/null
fi
