-- ============================================================
-- CONFIG.LUA
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- 📖 قناة الشروحات والتحديثات: @alaxla
-- ============================================================

local Config = {
    token = "8944887532:AAHYGMATmiYwFJLeV-7KqaQdsNUqsT4S6do",
    SUDO = \8880791326,
    bot_id = 0,
    api_url = "",
    version = "6.1",
    build_date = "2024-11-15",
    bot_name = "Dark Shield",
    developer = "@a11y11",
    channel = "@alaxla",
    tutorials = "@alaxla",
    source = "@alaxla",
    support = "@a11y11",
    debug = false,
    timeout = 30,
    limit = 100
}

function Config.init()
    Config.api_url = "https://api.telegram.org/bot" .. Config.token
    Config.bot_id = Config.token:match("(%d+)") or 0
end

return Config