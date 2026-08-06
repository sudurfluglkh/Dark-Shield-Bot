FROM luakit/luarocks:5.4-latest

WORKDIR /app

# تثبيت الحزم
RUN luarocks install lua-resty-redis
RUN luarocks install lua-https
RUN luarocks install dkjson

# تثبيت yt-dlp (اختياري)
RUN apt-get update && apt-get install -y python3-pip && pip3 install yt-dlp

# نسخ الملفات
COPY . .

# إنشاء المجلدات
RUN mkdir -p logs data/backups data/redis

# الصلاحيات
RUN chmod +x scripts/*.sh

CMD ["lua", "src/Dark.lua"]
