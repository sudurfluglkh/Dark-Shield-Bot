#!/bin/bash
# إعادة تشغيل Dark Shield Bot
# 📅 2024-11-15
# 👨‍💻 @a11y11

echo "🔄 Restarting Dark Shield Bot..."
./scripts/stop.sh
sleep 2
./scripts/start.sh
