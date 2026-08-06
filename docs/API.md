# Dark Shield Bot — API Documentation

## Base URL
```
http://localhost:8080/api
```

## Endpoints

### GET /api/status
حالة البوت
```json
{ "status": "online", "bot_name": "Dark Shield", "version": "7.0" }
```

### GET /api/stats
إحصائيات عامة
```json
{ "messages": 0, "users": 0, "groups": 0 }
```

### POST /api/send
إرسال رسالة
```json
{ "chat_id": 123, "text": "Hello" }
```

### GET /api/groups
قائمة المجموعات

### GET /api/group/:id/settings
إعدادات مجموعة معينة

### POST /api/group/:id/settings
تحديث إعدادات مجموعة
