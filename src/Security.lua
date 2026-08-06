-- ============================================================
-- SECURITY.LUA — نظام الحماية الكامل
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- 📖 قناة الشروحات والتحديثات: @alaxla
-- ============================================================

local Config = dofile("./src/Config.lua")
local BotAPI = dofile("./src/BotAPI.lua")
local Redis = dofile("./src/Redis.lua")
local Logger = dofile("./src/Logger.lua")

local Security = {}

-- ============================================================
-- [1. منع الروابط]
-- ============================================================
function Security.contains_link(text)
    if not text then return false end
    -- روابط http/https
    if text:match("https?://") then return true end
    -- روابط www
    if text:match("www%.") then return true end
    -- روابط t.me
    if text:match("t%.me/") then return true end
    -- معرفات تيليجرام @username (5+ حروف)
    if text:match("@[a-zA-Z0-9_]{5,}") then return true end
    return false
end

function Security.is_whitelisted_link(text)
    if not text then return false end
    -- روابط موثوقة يمكن السماح بها
    local whitelist = {
        "t.me/axla",
        "t.me/alaxla",
        "telegram.org",
    }
    for _, w in ipairs(whitelist) do
        if text:match(w) then return true end
    end
    return false
end

-- ============================================================
-- [2. منع التكرار (Flood)]
-- ============================================================
function Security.check_flood(chat_id, user_id)
    local key = "flood:" .. chat_id .. ":" .. user_id
    local count = Redis.incr(key)
    if count == 1 then
        Redis.expire(key, Config.flood_window)
    end
    return count > Config.flood_limit
end

-- ============================================================
-- [3. كشف الهجمات الجماعية (Raid)]
-- ============================================================
function Security.check_raid(chat_id)
    local key = "raid:" .. chat_id
    local count = Redis.incr(key)
    if count == 1 then
        Redis.expire(key, Config.raid_window)
    end
    return count > Config.raid_limit
end

-- ============================================================
-- [4. منع البوتات]
-- ============================================================
function Security.is_bot(user)
    if not user then return false end
    return user.is_bot == true
end

-- ============================================================
-- [5. فلتر الكلمات المسيئة]
-- ============================================================
function Security.contains_bad_word(text)
    if not text then return false end
    local key = "badwords:" .. Config.bot_id
    local words = Redis.smembers(key)
    if not words or #words == 0 then return false end
    local text_lower = text:lower()
    for _, word in ipairs(words) do
        if text_lower:match(word:lower()) then
            return true, word
        end
    end
    return false
end

function Security.add_bad_word(word)
    local key = "badwords:" .. Config.bot_id
    Redis.sadd(key, word)
    Logger.info("Bad word added: " .. word)
end

function Security.remove_bad_word(word)
    local key = "badwords:" .. Config.bot_id
    Redis.srem(key, word)
end

function Security.list_bad_words()
    local key = "badwords:" .. Config.bot_id
    return Redis.smembers(key)
end

function Security.clear_bad_words()
    local key = "badwords:" .. Config.bot_id
    local words = Redis.smembers(key)
    for _, w in ipairs(words) do
        Redis.srem(key, w)
    end
end

-- ============================================================
-- [6. نظام التحذيرات]
-- ============================================================
function Security.warn_user(chat_id, user_id)
    local key = "warns:" .. chat_id .. ":" .. user_id
    local count = Redis.incr(key)
    return count
end

function Security.get_warnings(chat_id, user_id)
    local key = "warns:" .. chat_id .. ":" .. user_id
    local val = Redis.get(key)
    return tonumber(val) or 0
end

function Security.reset_warnings(chat_id, user_id)
    local key = "warns:" .. chat_id .. ":" .. user_id
    Redis.del(key)
end

-- ============================================================
-- [7. تقييد المستخدم (Mute)]
-- ============================================================
function Security.mute_user(chat_id, user_id, duration)
    local until_date = os.time() + (duration or 3600)
    local params = {
        chat_id = chat_id,
        user_id = user_id,
        permissions = '{"can_send_messages": false, "can_send_media": false, "can_send_other": false, "can_add_previews": false}'
    }
    if duration then
        params.until_date = until_date
    end
    return BotAPI.request("restrictChatMember", params)
end

function Security.unmute_user(chat_id, user_id)
    local permissions = '{"can_send_messages": true, "can_send_media": true, "can_send_other": true, "can_add_previews": true, "can_invite_users": true, "can_change_info": false, "can_pin_messages": false}'
    return BotAPI.request("restrictChatMember", {
        chat_id = chat_id,
        user_id = user_id,
        permissions = permissions
    })
end

-- ============================================================
-- [8. طرد مستخدم]
-- ============================================================
function Security.kick_user(chat_id, user_id)
    local ok = BotAPI.request("kickChatMember", {chat_id = chat_id, user_id = user_id})
    if ok then
        -- إلغاء الحظر فوراً عشان يقدر يرجع
        BotAPI.request("unbanChatMember", {chat_id = chat_id, user_id = user_id, only_if_banned = "true"})
    end
    return ok
end

function Security.ban_user(chat_id, user_id)
    return BotAPI.request("kickChatMember", {chat_id = chat_id, user_id = user_id})
end

function Security.unban_user(chat_id, user_id)
    return BotAPI.request("unbanChatMember", {chat_id = chat_id, user_id = user_id, only_if_banned = "true"})
end

-- ============================================================
-- [9. قفل/فتح المجموعة]
-- ============================================================
function Security.lock_chat(chat_id)
    local permissions = '{"can_send_messages": false, "can_send_media": false, "can_send_other": false, "can_add_previews": false, "can_invite_users": false, "can_change_info": false, "can_pin_messages": false}'
    return BotAPI.request("setChatPermissions", {chat_id = chat_id, permissions = permissions})
end

function Security.unlock_chat(chat_id)
    local permissions = '{"can_send_messages": true, "can_send_media": true, "can_send_other": true, "can_add_previews": true, "can_invite_users": true, "can_change_info": false, "can_pin_messages": false}'
    return BotAPI.request("setChatPermissions", {chat_id = chat_id, permissions = permissions})
end

-- ============================================================
-- [10. حذف الرسالة]
-- ============================================================
function Security.delete_message(chat_id, message_id)
    return BotAPI.request("deleteMessage", {chat_id = chat_id, message_id = message_id})
end

-- ============================================================
-- [11. التحقق من الأدمن]
-- ============================================================
function Security.is_admin(chat_id, user_id)
    if user_id == Config.SUDO then return true end
    local res = BotAPI.request("getChatMember", {chat_id = chat_id, user_id = user_id})
    if not res or not res.ok then return false end
    local status = res.result and res.result.status or ""
    return status == "administrator" or status == "creator"
end

function Security.is_sudo(user_id)
    return user_id == Config.SUDO
end

-- ============================================================
-- [12. حماية المجموعة الرئيسية]
-- ============================================================
function Security.protect_message(msg)
    if not msg or not msg.text then return false end
    local chat_id = msg.chat.id
    local user_id = msg.from and msg.from.id or 0

    -- الأدمن معفي
    if Security.is_admin(chat_id, user_id) then return false end

    local settings = Security.get_group_settings(chat_id)
    if not settings.protection then return false end

    local text = msg.text or msg.caption or ""

    -- 1. منع الروابط
    if settings.anti_link and Security.contains_link(text) then
        if not Security.is_whitelisted_link(text) then
            Security.delete_message(chat_id, msg.message_id)
            Security.warn_user(chat_id, user_id)
            BotAPI.sendMessage(chat_id, "🚫 الروابط ممنوعة!")
            return true
        end
    end

    -- 2. فلتر الكلمات
    if settings.bad_words_filter then
        local found, word = Security.contains_bad_word(text)
        if found then
            Security.delete_message(chat_id, msg.message_id)
            local warns = Security.warn_user(chat_id, user_id)
            if warns >= Config.max_warnings then
                Security.kick_user(chat_id, user_id)
                Security.reset_warnings(chat_id, user_id)
                BotAPI.sendMessage(chat_id, "🚫 تم طرد المستخدم بسبب تكرار المخالفات.")
            else
                BotAPI.sendMessage(chat_id, "🤬 يمنع الكلمات المسيئة! تحذير " .. warns .. "/" .. Config.max_warnings)
            end
            return true
        end
    end

    -- 3. منع التكرار
    if settings.anti_flood and Security.check_flood(chat_id, user_id) then
        Security.delete_message(chat_id, msg.message_id)
        local warns = Security.warn_user(chat_id, user_id)
        if warns >= Config.max_warnings then
            Security.mute_user(chat_id, user_id, 3600)
            Security.reset_warnings(chat_id, user_id)
            BotAPI.sendMessage(chat_id, "🔇 تم تقييد المستخدم ساعة بسبب التكرار.")
        else
            BotAPI.sendMessage(chat_id, "🌊 لا تكرر الرسائل! تحذير " .. warns .. "/" .. Config.max_warnings)
        end
        return true
    end

    return false
end

-- ============================================================
-- [13. إعدادات المجموعة]
-- ============================================================
function Security.get_group_settings(chat_id)
    local key = "settings:" .. chat_id
    local data = Redis.hgetall(key)
    if not data or next(data) == nil then
        -- إعدادات افتراضية
        local defaults = {
            protection = "true",
            anti_link = "true",
            anti_flood = "true",
            anti_bot = "true",
            anti_raid = "true",
            bad_words_filter = "true",
            welcome = "true",
            goodbye = "true",
        }
        for k, v in pairs(defaults) do
            Redis.hset(key, k, v)
        end
        return defaults
    end
    return data
end

function Security.set_group_setting(chat_id, setting, value)
    local key = "settings:" .. chat_id
    Redis.hset(key, setting, tostring(value))
end

-- ============================================================
-- [14. حماية دخول الأعضاء]
-- ============================================================
function Security.on_new_member(msg)
    local chat_id = msg.chat.id
    local settings = Security.get_group_settings(chat_id)

    if not settings.protection then return end

    -- كشف الهجوم الجماعي
    if settings.anti_raid == "true" and Security.check_raid(chat_id) then
        BotAPI.sendMessage(chat_id, "⚔️ تم رصد هجوم جماعي! تم تفعيل القفل المؤقت.")
        Security.lock_chat(chat_id)
        -- فتح بعد 60 ثانية
        os.execute("sleep 60")
        Security.unlock_chat(chat_id)
    end

    for _, member in ipairs(msg.new_chat_members or {}) do
        -- منع البوتات
        if settings.anti_bot == "true" and Security.is_bot(member) then
            Security.kick_user(chat_id, member.id)
            BotAPI.sendMessage(chat_id, "🤖 تم طرد البوت @" .. (member.username or "unknown") .. " تلقائياً.")
        end
    end
end

return Security
