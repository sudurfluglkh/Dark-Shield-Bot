-- ============================================================
-- AUTH.LUA — نظام الصلاحيات
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local Config = dofile("./src/Config.lua")
local Redis = dofile("./src/Redis.lua")
local BotAPI = dofile("./src/BotAPI.lua")

local Auth = {}

-- مستويات الصلاحيات
Auth.LEVELS = {
    SUDO = 5,      -- المطور
    OWNER = 4,     -- مالك المجموعة
    ADMIN = 3,     -- أدمن
    MOD = 2,       -- مشرف
    MEMBER = 1,    -- عضو عادي
    BANNED = 0,    -- محظور
}

-- الحصول على مستوى صلاحية المستخدم
function Auth.get_level(chat_id, user_id)
    -- SUDO له كل الصلاحيات
    if user_id == Config.SUDO then
        return Auth.LEVELS.SUDO
    end

    -- تحقق من Ban
    if Redis.sismember("banned:" .. chat_id, tostring(user_id)) then
        return Auth.LEVELS.BANNED
    end

    -- تحقق من المشرفين المخصصين
    local mod_level = Redis.get("mod:" .. chat_id .. ":" .. user_id)
    if mod_level then
        return tonumber(mod_level) or Auth.LEVELS.MEMBER
    end

    -- تحقق من Telegram Admin
    local res = BotAPI.request("getChatMember", {chat_id = chat_id, user_id = user_id})
    if res and res.ok and res.result then
        local status = res.result.status
        if status == "creator" then return Auth.LEVELS.OWNER end
        if status == "administrator" then return Auth.LEVELS.ADMIN end
    end

    return Auth.LEVELS.MEMBER
end

-- التحقق إن كان المستخدم أدمن أو أعلى
function Auth.is_admin(chat_id, user_id)
    return Auth.get_level(chat_id, user_id) >= Auth.LEVELS.ADMIN
end

-- التحقق إن كان المستخدم SUDO
function Auth.is_sudo(user_id)
    return user_id == Config.SUDO
end

-- التحقق من صلاحية معينة
function Auth.has_permission(chat_id, user_id, required_level)
    return Auth.get_level(chat_id, user_id) >= (required_level or Auth.LEVELS.ADMIN)
end

-- ترقية مستخدم لمشرف
function Auth.set_mod(chat_id, user_id, level)
    Redis.set("mod:" .. chat_id .. ":" .. user_id, tostring(level or Auth.LEVELS.MOD))
end

-- إزالة مشرف
function Auth.remove_mod(chat_id, user_id)
    Redis.del("mod:" .. chat_id .. ":" .. user_id)
end

-- حظر مستخدم من استخدام البوت
function Auth.ban_user(chat_id, user_id)
    Redis.sadd("banned:" .. chat_id, tostring(user_id))
end

-- إلغاء حظر
function Auth.unban_user(chat_id, user_id)
    Redis.srem("banned:" .. chat_id, tostring(user_id))
end

-- التحقق من الحظر
function Auth.is_banned(chat_id, user_id)
    return Redis.sismember("banned:" .. chat_id, tostring(user_id))
end

return Auth
