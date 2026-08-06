-- ============================================================
-- LOGGER.LUA — نظام تسجيل الأحداث
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local Config = dofile("./src/Config.lua")

local Logger = {}

-- مستويات السجل
Logger.LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    FATAL = 5,
}

local level_names = {[1]="DEBUG", [2]="INFO", [3]="WARN", [4]="ERROR", [5]="FATAL"}
local level_emojis = {[1]="🔍", [2]="ℹ️", [3]="⚠️", [4]="❌", [5]="💀"}

-- الحصول على الطابع الزمني
local function timestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

-- كتابة للسجل
local function write_log(level, msg)
    local ts = timestamp()
    local level_name = level_names[level] or "INFO"
    local emoji = level_emojis[level] or "ℹ️"
    local line = string.format("[%s] %s [%s] %s", ts, emoji, level_name, msg)

    -- طباعة في الكونسول
    print(line)

    -- كتابة للملف
    local log_file = "./logs/bot.log"
    local file = io.open(log_file, "a")
    if file then
        file:write(line .. "\n")
        file:close()
    end
end

-- دوال عامة
function Logger.debug(msg)
    if Config.debug then
        write_log(Logger.LEVELS.DEBUG, msg)
    end
end

function Logger.info(msg)
    write_log(Logger.LEVELS.INFO, msg)
end

function Logger.warn(msg)
    write_log(Logger.LEVELS.WARN, msg)
end

function Logger.error(msg)
    write_log(Logger.LEVELS.ERROR, msg)
end

function Logger.fatal(msg)
    write_log(Logger.LEVELS.FATAL, msg)
end

-- تسجيل رسالة مستخدم
function Logger.log_message(msg)
    if not msg then return end
    local chat_id = msg.chat and msg.chat.id or "?"
    local user_id = msg.from and msg.from.id or "?"
    local user_name = msg.from and msg.from.first_name or "?"
    local text = msg.text or msg.caption or "[media]"
    Logger.debug(string.format("MSG [%s] %s(%s): %s", tostring(chat_id), user_name, tostring(user_id), text))
end

-- تسجيل أمر
function Logger.log_command(chat_id, user_id, command)
    Logger.info(string.format("CMD [%s] User %s: %s", tostring(chat_id), tostring(user_id), command))
end

-- تسجيل إجراء أمني
function Logger.log_security(chat_id, user_id, action, reason)
    Logger.warn(string.format("SEC [%s] User %s: %s (%s)", tostring(chat_id), tostring(user_id), action, reason))
end

-- مسح السجلات القديمة
function Logger.clear_old_logs(days)
    days = days or 7
    local cmd = string.format('find ./logs/ -name "*.log" -mtime +%d -delete 2>/dev/null', days)
    os.execute(cmd)
    Logger.info("Old logs cleared (>" .. days .. " days)")
end

-- عرض آخر السجلات
function Logger.tail(lines)
    lines = lines or 50
    local cmd = string.format('tail -n %d ./logs/bot.log 2>/dev/null', lines)
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()
    return result or "لا توجد سجلات"
end

return Logger
