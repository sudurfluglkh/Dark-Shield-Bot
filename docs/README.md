# Dark Shield Bot

## الوثائق

- [API.md](API.md) — وثائق الـ API
- [COMMANDS.md](COMMANDS.md) — قائمة الأوامر الكاملة

## التشغيل

### المتطلبات
- Lua 5.4+
- Redis 7.x+
- LuaRocks (لإدارة الحزم)

### التثبيت
```bash
luarocks install lua-resty-redis
luarocks install lua-https
luarocks install dkjson
```

### الإعداد
```bash
cp env.example .env
# عدل القيم في .env
```

### التشغيل
```bash
./scripts/start.sh
```

### Docker
```bash
docker-compose up -d
```

## الهيكل
```
src/          — الكود المصدري
data/         — البيانات والكلايش
logs/         — السجلات
scripts/      — سكربتات التشغيل
server/       — سيرفر API
docs/         — الوثائق
```
