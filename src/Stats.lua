-- ============================================================
-- STATS.LUA — نظام الإحصائيات
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local Config = dofile("./src/Config.lua")
local Redis = dofile("./src/Redis.lua")
local BotAPI = dofile("./src/BotAPI.lua")

local Stats = {}

-- زيادة عداد
function Stats.increment(key)
    local k = "stats:" .. key
    return Redis.incr(k)
end

-- الحصول على عداد
function Stats.get(key)
    local k = "stats:" .. key
    return tonumber(Redis.get(k)) or 0
end

-- زيادة رسالة
function Stats.message_sent(chat_id, user_id)
    Stats.increment("messages:total")
    Stats.increment("messages:" .. chat_id)
    Stats.increment("user:" .. user_id .. ":messages")
    -- آخر نشاط
    Redis.set("user:" .. user_id .. ":last_active", tostring(os.time()))
end

-- تسجيل مستخدم جديد
function Stats.new_user(chat_id, user_id)
    local key = "users:" .. chat_id
    if not Redis.sismember(key, tostring(user_id)) then
        Redis.sadd(key, tostring(user_id))
        Stats.increment("users:total")
    end
end

-- تسجيل مجموعة جديدة
function Stats.new_group(chat_id)
    local key = "groups"
    if not Redis.sismember(key, tostring(chat_id)) then
        Redis.sadd(key, tostring(chat_id))
        Stats.increment("groups:total")
    end
end

-- عرض إحصائيات المستخدم
function Stats.user_stats(msg)
    local chat_id = msg.chat.id
    local user_id = msg.from.id
    local messages = Stats.get("user:" .. user_id .. ":messages")
    local last_active = Redis.get("user:" .. user_id .. ":last_active")
    local last_text = "غير معروف"
    if last_active then
        last_text = os.date("%Y-%m-%d %H:%M:%S", tonumber(last_active))
    end
    local text = "📊 إحصائيات المستخدم\n\n"
    text = text .. "📝 الرسائل: " .. messages .. "\n"
    text = text .. "🕐 آخر نشاط: " .. last_text .. "\n"
    BotAPI.sendMessage(chat_id, text)
end

-- عرض إحصائيات المجموعة
function Stats.group_stats(msg)
    local chat_id = msg.chat.id
    local messages = Stats.get("messages:" .. chat_id)
    local users = Redis.smembers("users:" .. chat_id)
    local text = "📊 إحصائيات المجموعة\n\n"
    text = text .. "📝 الرسائل: " .. messages .. "\n"
    text = text .. "👥 الأعضاء المسجلون: " .. (#users or 0) .. "\n"
    text = text .. "🆔 ID: " .. tostring(chat_id) .. "\n"
    BotAPI.sendMessage(chat_id, text)
end

-- عرض إحصائيات عامة (SUDO فقط)
function Stats.global_stats(msg)
    local total_messages = Stats.get("messages:total")
    local total_users = Stats.get("users:total")
    local total_groups = Stats.get("groups:total")
    local groups = Redis.smembers("groups")
    local text = "📊 الإحصائيات العامة\n\n"
    text = text .. "📝 إجمالي الرسائل: " .. total_messages .. "\n"
    text = text .. "👥 إجمالي المستخدمين: " .. total_users .. "\n"
    text = text .. "💬 إجمالي المجموعات: " .. total_groups .. "\n"
    text = text .. "🔄 المجموعات النشطة: " .. (#groups or 0) .. "\n"
    text = text .. "🤖 البوت: " .. Config.bot_name .. " v" .. Config.version .. "\n"
    BotAPI.sendMessage(msg.chat.id, text)
end

-- عرض الإحصائيات (توجيه للأمر المناسب)
function Stats.show_stats(msg)
    if msg.from.id == Config.SUDO then
        Stats.global_stats(msg)
    else
        Stats.user_stats(msg)
    end
end

return Stats
