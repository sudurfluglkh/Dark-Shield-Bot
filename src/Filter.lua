-- ============================================================
-- FILTER.LUA — نظام فلترة المحتوى
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local Config = dofile("./src/Config.lua")
local BotAPI = dofile("./src/BotAPI.lua")
local Redis = dofile("./src/Redis.lua")
local Security = dofile("./src/Security.lua")
local Logger = dofile("./src/Logger.lua")

local Filter = {}

-- ============================================================
-- [1. فلتر الروابط المتقدم]
-- ============================================================
function Filter.check_links(msg)
    if not msg then return false end
    local text = msg.text or msg.caption or ""
    if text == "" then return false end

    local chat_id = msg.chat.id
    local settings = Security.get_group_settings(chat_id)
    if settings.anti_link ~= "true" then return false end

    -- استخراج الروابط
    local links = {}
    for link in text:gmatch("https?://[%w%-%._~:/?#@!$&'%()*+,;=]+") do
        table.insert(links, link)
    end
    for link in text:gmatch("www%.[%w%-%._~:/?#@!$&'%()*+,;=]+") do
        table.insert(links, "http://" .. link)
    end
    for link in text:gmatch("t%.me/[.%w%-_]+") do
        table.insert(links, "https://" .. link)
    end

    if #links == 0 then return false end

    -- تحقق من القائمة البيضاء
    local whitelist_key = "whitelist:" .. chat_id
    for _, link in ipairs(links) do
        local is_whitelisted = false
        local whitelist = Redis.smembers(whitelist_key)
        for _, w in ipairs(whitelist) do
            if link:match(w) then
                is_whitelisted = true
                break
            end
        end
        if not is_whitelisted then
            return true
        end
    end

    return false
end

-- ============================================================
-- [2. فلتر الوسائط]
-- ============================================================
function Filter.check_media(msg)
    if not msg then return false end
    local chat_id = msg.chat.id
    local settings = Security.get_group_settings(chat_id)

    -- فلتر الصور المتكررة (تحقق بسيط)
    if settings.anti_sticker == "true" and msg.sticker then
        -- يمكن إضافة منطق لمنع البصمات المتكررة
    end

    -- فلتر الفيديوهات/الملفات الكبيرة
    if msg.video and msg.video.file_size and msg.video.file_size > 50 * 1024 * 1024 then
        if settings.anti_large_files ~= "false" then
            return true
        end
    end

    if msg.document and msg.document.file_size and msg.document.file_size > 50 * 1024 * 1024 then
        if settings.anti_large_files ~= "false" then
            return true
        end
    end

    return false
end

-- ============================================================
-- [3. فلتر التحويل (Forward)]
-- ============================================================
function Filter.check_forward(msg)
    if not msg then return false end
    local chat_id = msg.chat.id
    local settings = Security.get_group_settings(chat_id)

    if settings.anti_forward == "true" and msg.forward_from then
        return true
    end

    if settings.anti_forward == "true" and msg.forward_from_chat then
        return true
    end

    return false
end

-- ============================================================
-- [4. إدارة القائمة البيضاء للروابط]
-- ============================================================
function Filter.add_whitelist(chat_id, domain)
    Redis.sadd("whitelist:" .. chat_id, domain)
    Logger.info("Whitelisted: " .. domain .. " in " .. tostring(chat_id))
end

function Filter.remove_whitelist(chat_id, domain)
    Redis.srem("whitelist:" .. chat_id, domain)
end

function Filter.list_whitelist(chat_id)
    return Redis.smembers("whitelist:" .. chat_id)
end

-- ============================================================
-- [5. فلتر كامل للرسالة]
-- ============================================================
function Filter.check_message(msg)
    if not msg then return false end
    local chat_id = msg.chat.id
    local user_id = msg.from and msg.from.id or 0

    -- الأدمن معفي
    if Security.is_admin(chat_id, user_id) then return false, nil end

    -- فحص الروابط
    if Filter.check_links(msg) then
        return true, "link"
    end

    -- فحص الوسائط
    if Filter.check_media(msg) then
        return true, "media"
    end

    -- فحص التحويل
    if Filter.check_forward(msg) then
        return true, "forward"
    end

    return false, nil
end

-- ============================================================
-- [6. معالجة الرسالة المخالفة]
-- ============================================================
function Filter.handle(msg)
    local blocked, reason = Filter.check_message(msg)
    if not blocked then return false end

    local chat_id = msg.chat.id
    local user_id = msg.from and msg.from.id or 0

    Security.delete_message(chat_id, msg.message_id)

    local reason_text = {
        link = "🚫 الروابط ممنوعة!",
        media = "📁 الملفات الكبيرة ممنوعة!",
        forward = "📤 التحويلات ممنوعة!",
    }

    local warns = Security.warn_user(chat_id, user_id)
    if warns >= Config.max_warnings then
        Security.mute_user(chat_id, user_id, 3600)
        Security.reset_warnings(chat_id, user_id)
        BotAPI.sendMessage(chat_id, "🔇 تم تقييد المستخدم.")
    else
        BotAPI.sendMessage(chat_id, (reason_text[reason] or "🚫 محتوى ممنوع") .. " تحذير " .. warns .. "/" .. Config.max_warnings)
    end

    Logger.warn("Filter blocked: " .. reason .. " from " .. tostring(user_id))
    return true
end

return Filter
