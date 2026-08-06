-- ============================================================
-- ANTISPAM.LUA — نظام مكافحة السبام المتقدم
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local Config = dofile("./src/Config.lua")
local BotAPI = dofile("./src/BotAPI.lua")
local Redis = dofile("./src/Redis.lua")
local Security = dofile("./src/Security.lua")
local Logger = dofile("./src/Logger.lua")

local AntiSpam = {}

-- ============================================================
-- [1. كشف السبام المتكرر]
-- ============================================================
function AntiSpam.check_repeat(chat_id, user_id, text)
    if not text or text == "" then return false end
    local key = "lastmsg:" .. chat_id .. ":" .. user_id
    local last_msg = Redis.get(key)
    local last_count_key = "lastcount:" .. chat_id .. ":" .. user_id
    local count = tonumber(Redis.get(last_count_key)) or 0

    if last_msg == text then
        count = count + 1
        Redis.set(last_count_key, tostring(count))
        if count >= 3 then
            -- رسائل متكررة 3+ مرات
            Redis.del(key)
            Redis.del(last_count_key)
            return true
        end
    else
        Redis.set(key, text)
        Redis.set(last_count_key, "1")
    end
    return false
end

-- ============================================================
-- [2. كشف السبام بالإعلانات]
-- ============================================================
function AntiSpam.is_advertisement(text)
    if not text then return false end
    local ad_patterns = {
        "تبادل", "لايك", "اشتراك", "تابعني", "شاهد المزيد",
        "اضغط هنا", "للطلب", "للحجز", "واتساب", "تسوق",
        "خصم", "عرض خاص", "مجاناً", "ربح",
    }
    for _, pattern in ipairs(ad_patterns) do
        if text:lower():match(pattern) then
            return true
        end
    end
    return false
end

-- ============================================================
-- [3. كشف الحروف العشوائية]
-- ============================================================
function AntiSpam.is_random_chars(text)
    if not text or #text < 10 then return false end
    -- عد الحروف المتكررة
    local same_char = text:match("(.+)%1%1%1%1%1")
    if same_char then return true end
    -- كشف نص بأحرف عشوائية (بدون كلمات حقيقية)
    local alpha_count = 0
    for _ in text:gmatch("[a-zA-Z]") do alpha_count = alpha_count + 1 end
    if alpha_count > #text * 0.8 and not text:match("%s") then
        return true
    end
    return false
end

-- ============================================================
-- [4. تتبع نشاط المستخدم]
-- ============================================================
function AntiSpam.track_user(chat_id, user_id)
    local key = "activity:" .. chat_id .. ":" .. user_id
    local count = Redis.incr(key)
    if count == 1 then
        Redis.expire(key, 60)  -- نافذة دقيقة واحدة
    end
    return count
end

-- ============================================================
-- [5. كشف المستخدمين المشبوهين]
-- ============================================================
function AntiSpam.is_suspicious(chat_id, user_id, text)
    -- الكثير من الرسائل في وقت قصير
    local activity = AntiSpam.track_user(chat_id, user_id)
    if activity > 20 then
        return true, "نشاط مفرط"
    end

    -- رسائل متكررة
    if AntiSpam.check_repeat(chat_id, user_id, text) then
        return true, "رسائل متكررة"
    end

    -- إعلانات
    if AntiSpam.is_advertisement(text) then
        return true, "إعلان"
    end

    -- أحرف عشوائية
    if AntiSpam.is_random_chars(text) then
        return true, "أحرف عشوائية"
    end

    return false
end

-- ============================================================
-- [6. معالجة السبام]
-- ============================================================
function AntiSpam.handle(msg)
    if not msg or not msg.text then return false end
    local chat_id = msg.chat.id
    local user_id = msg.from and msg.from.id or 0

    -- الأدمن معفي
    if Security.is_admin(chat_id, user_id) then return false end

    local suspicious, reason = AntiSpam.is_suspicious(chat_id, user_id, msg.text)
    if suspicious then
        Security.delete_message(chat_id, msg.message_id)
        local warns = Security.warn_user(chat_id, user_id)
        if warns >= Config.max_warnings then
            Security.mute_user(chat_id, user_id, 3600)
            Security.reset_warnings(chat_id, user_id)
            BotAPI.sendMessage(chat_id, "🔇 تم كتم المستخدم بسبب السبام (" .. reason .. ")")
        else
            BotAPI.sendMessage(chat_id, "⚠️ تحذير " .. warns .. "/" .. Config.max_warnings .. " - " .. reason)
        end
        Logger.warn("Spam detected: " .. reason .. " from user " .. tostring(user_id))
        return true
    end

    return false
end

-- ============================================================
-- [7. قائمة المستخدمين المقيدين]
-- ============================================================
function AntiSpam.list_restricted(chat_id)
    local key = "muted:" .. chat_id
    return Redis.smembers(key)
end

-- ============================================================
-- [8. إضافة/إزالة من قائمة المقيدين]
-- ============================================================
function AntiSpam.add_restricted(chat_id, user_id)
    Redis.sadd("muted:" .. chat_id, tostring(user_id))
end

function AntiSpam.remove_restricted(chat_id, user_id)
    Redis.srem("muted:" .. chat_id, tostring(user_id))
end

return AntiSpam
