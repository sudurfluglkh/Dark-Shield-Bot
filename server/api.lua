-- ============================================================
-- API.LUA — واجهة API الخارجية
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local Config = dofile("./src/Config.lua")
local BotAPI = dofile("./src/BotAPI.lua")
local Logger = dofile("./src/Logger.lua")

local API = {}

-- إرسال رسالة عبر API
function API.send_message(chat_id, text)
    return BotAPI.sendMessage(chat_id, text)
end

-- الحصول على معلومات البوت
function API.get_me()
    return BotAPI.request("getMe", {})
end

-- الحصول على معلومات مجموعة
function API.get_chat(chat_id)
    return BotAPI.request("getChat", {chat_id = chat_id})
end

-- تعيين وضع الـ webhook
function API.set_webhook(url)
    return BotAPI.request("setWebhook", {url = url})
end

-- حذف الـ webhook
function API.delete_webhook()
    return BotAPI.request("deleteWebhook", {})
end

-- الحصول على عدد أعضاء المجموعة
function API.get_member_count(chat_id)
    local res = BotAPI.request("getChatMemberCount", {chat_id = chat_id})
    if res and res.ok then
        return res.result
    end
    return 0
end

return API
