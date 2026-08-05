# استخدام نظام أوبونتو الأساسي
FROM ubuntu:20.04

# منع المطالبات التفاعلية أثناء التثبيت
ENV DEBIAN_FRONTEND=noninteractive

# تثبيت حزم Lua ومكتبات SSL اللازمة
RUN apt-get update && apt-get install -y \
    lua5.3 \
    liblua5.3-dev \
    luarocks \
    libssl-dev \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# تثبيت مكتبات Lua المطلوبة
RUN luarocks install luasec
RUN luarocks install luasocket

# تحديد مجلد العمل
WORKDIR /app

# نسخ جميع ملفات السورس إلى مجلد العمل
COPY . .

# أمر تشغيل البوت
CMD ["lua5.3", "src/Dark.lua"]
