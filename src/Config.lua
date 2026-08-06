-- ============================================================
-- CONFIG.LUA
-- ============================================================
-- 📅 التاريخ: 2024-11-15 (تم الإصلاح: 2026-08-06)
-- 👨‍💻 المبرمج والمطور: @a11y11
-- 📖 قناة الشروحات والتحديثات: @alaxla
-- ============================================================

local os = os

local Config = {
    -- التوكن يُقرأ من متغير البيئة (أكثر أماناً)
    token = os.getenv("BOT_TOKEN") or "8944887532:AAHYGMATmiYwFJLeV-7KqaQdsNUqsT4S6do",
    SUDO = 8880791326,  -- تم إصلاح الخطأ (كان \8880791326)
    bot_id = 0,
    api_url = "",
    version = "7.0",
    build_date = "2024-11-15",
    bot_name = "Dark Shield",
    developer = "@a11y11",
    channel = "@alaxla",
    tutorials = "@alaxla",
    source = "@alaxla",
    support = "@a11y11",
    debug = false,
    timeout = 30,
    limit = 100,

    -- إعدادات Redis
    redis_host = os.getenv("REDIS_HOST") or "127.0.0.1",
    redis_port = tonumber(os.getenv("REDIS_PORT") or "6379"),
    redis_db = tonumber(os.getenv("REDIS_DB") or "0"),

    -- إعدادات الحماية
    max_warnings = 3,
    flood_limit = 5,
    flood_window = 5,
    raid_limit = 7,
    raid_window = 10,

    -- مفاتيح Redis
    prefix = "darkshield:",
}

function Config.init()
    Config.api_url = "https://api.telegram.org/bot" .. Config.token
    Config.bot_id = tonumber(Config.token:match("(%d+)")) or 0
    print("[Config] Bot ID: " .. tostring(Config.bot_id))
    print("[Config] API URL: " .. Config.api_url)
end

return Config
