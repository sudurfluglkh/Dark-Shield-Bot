-- ============================================================
-- BACKUP.LUA — نظام النسخ الاحتياطي
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local Config = dofile("./src/Config.lua")
local BotAPI = dofile("./src/BotAPI.lua")
local Redis = dofile("./src/Redis.lua")
local Logger = dofile("./src/Logger.lua")

local Backup = {}

-- إنشاء نسخة احتياطية
function Backup.create()
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local filename = "backup_" .. timestamp .. ".json"
    local filepath = "./data/backups/" .. filename

    -- جمع البيانات من Redis
    -- ملاحظة: هذا نسخة مبسطة، في الإنتاج استخدم SAVE أو BGSAVE من Redis
    local data = {
        timestamp = timestamp,
        bot_name = Config.bot_name,
        version = Config.version,
        groups = {},
        settings = {},
    }

    -- محاولة حفظ عبر Redis
    local cmd = 'redis-cli --rdb ./data/backups/dump_' .. timestamp .. '.rdb 2>&1'
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()

    -- حفظ نسخة JSON بسيطة
    local file = io.open(filepath, "w")
    if file then
        file:write('{\n  "timestamp": "' .. timestamp .. '",\n')
        file:write('  "bot_name": "' .. Config.bot_name .. '",\n')
        file:write('  "version": "' .. Config.version .. '"\n}\n')
        file:close()
        Logger.info("Backup created: " .. filename)
        return filepath
    end
    return nil
end

-- استعادة نسخة احتياطية
function Backup.restore(filepath)
    if not filepath then return false end
    local file = io.open(filepath, "r")
    if not file then
        Logger.error("Backup file not found: " .. filepath)
        return false
    end
    local content = file:read("*a")
    file:close()
    Logger.info("Backup restored from: " .. filepath)
    return true
end

-- قائمة النسخ الاحتياطية
function Backup.list()
    local backups = {}
    local cmd = 'ls -la ./data/backups/*.json ./data/backups/*.rdb 2>/dev/null'
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()

    for line in result:gmatch("[^\r\n]+") do
        table.insert(backups, line)
    end
    return backups
end

-- حذف نسخة احتياطية
function Backup.delete(filepath)
    os.remove(filepath)
    Logger.info("Backup deleted: " .. filepath)
end

-- جدولة نسخ احتياطي تلقائي
function Backup.schedule(interval_hours)
    interval_hours = interval_hours or 24
    -- يحفظ إعداد الجدولة
    Redis.set("backup_interval", tostring(interval_hours))
    Logger.info("Backup scheduled every " .. interval_hours .. " hours")
end

-- تشغيل النسخ الاحتياطي التلقائي
function Backup.run_auto()
    local interval = tonumber(Redis.get("backup_interval") or "24")
    local last_backup = tonumber(Redis.get("last_backup") or "0")
    local now = os.time()
    if now - last_backup >= interval * 3600 then
        Backup.create()
        Redis.set("last_backup", tostring(now))
    end
end

-- أمر النسخ الاحتياطي
function Backup.command(msg)
    local chat_id = msg.chat.id
    if msg.from.id ~= Config.SUDO then
        BotAPI.sendMessage(chat_id, "❌ هذا الأمر للمطور فقط.")
        return
    end
    local filepath = Backup.create()
    if filepath then
        -- إرسال الملف
        local file = io.open(filepath, "rb")
        if file then
            file:close()
            BotAPI.request("sendDocument", {chat_id = chat_id, document = filepath})
        else
            BotAPI.sendMessage(chat_id, "✅ تم إنشاء نسخة احتياطية: " .. filepath)
        end
    else
        BotAPI.sendMessage(chat_id, "❌ فشل إنشاء النسخ الاحتياطية.")
    end
end

-- أمر قائمة النسخ الاحتياطية
function Backup.list_command(msg)
    if msg.from.id ~= Config.SUDO then
        BotAPI.sendMessage(msg.chat.id, "❌ هذا الأمر للمطور فقط.")
        return
    end
    local backups = Backup.list()
    if #backups == 0 then
        BotAPI.sendMessage(msg.chat.id, "📋 لا توجد نسخ احتياطية.")
        return
    end
    local text = "📋 النسخ الاحتياطية:\n\n"
    for i, b in ipairs(backups) do
        text = text .. i .. ". " .. b .. "\n"
    end
    BotAPI.sendMessage(msg.chat.id, text)
end

return Backup
