-- ============================================================
-- ADMIN.LUA — أوامر الأدمن (30+ أمر)
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local Config = dofile("./src/Config.lua")
local BotAPI = dofile("./src/BotAPI.lua")
local Redis = dofile("./src/Redis.lua")
local Security = dofile("./src/Security.lua")
local Logger = dofile("./src/Logger.lua")

local Admin = {}

-- ============================================================
-- [أوامر الحماية]
-- ============================================================

-- تفعيل/إيقاف الحماية
function Admin.toggle_protection(msg, args)
    local chat_id = msg.chat.id
    if not args or args == "" then
        local settings = Security.get_group_settings(chat_id)
        local status = settings.protection == "true" and "✅ مفعّل" or "❌ متوقف"
        BotAPI.sendMessage(chat_id, "🛡️ الحماية: " .. status .. "\nاستخدم: /حماية on|off")
        return
    end
    local value = args == "on" or args == "true"
    Security.set_group_setting(chat_id, "protection", tostring(value))
    BotAPI.sendMessage(chat_id, value and "✅ تم تفعيل الحماية." or "⏸️ تم إيقاف الحماية.")
end

-- تفعيل/إيقاف منع الروابط
function Admin.toggle_anti_link(msg, args)
    local chat_id = msg.chat.id
    local value = args == "on" or args == "true"
    Security.set_group_setting(chat_id, "anti_link", tostring(value))
    BotAPI.sendMessage(chat_id, value and "✅ تم تفعيل منع الروابط." or "⏸️ تم إيقاف منع الروابط.")
end

-- تفعيل/إيقاف منع التكرار
function Admin.toggle_anti_flood(msg, args)
    local chat_id = msg.chat.id
    local value = args == "on" or args == "true"
    Security.set_group_setting(chat_id, "anti_flood", tostring(value))
    BotAPI.sendMessage(chat_id, value and "✅ تم تفعيل منع التكرار." or "⏸️ تم إيقاف منع التكرار.")
end

-- تفعيل/إيقاف منع البوتات
function Admin.toggle_anti_bot(msg, args)
    local chat_id = msg.chat.id
    local value = args == "on" or args == "true"
    Security.set_group_setting(chat_id, "anti_bot", tostring(value))
    BotAPI.sendMessage(chat_id, value and "✅ تم تفعيل منع البوتات." or "⏸️ تم إيقاف منع البوتات.")
end

-- تفعيل/إيقاف فلتر الكلمات
function Admin.toggle_bad_words(msg, args)
    local chat_id = msg.chat.id
    local value = args == "on" or args == "true"
    Security.set_group_setting(chat_id, "bad_words_filter", tostring(value))
    BotAPI.sendMessage(chat_id, value and "✅ تم تفعيل فلتر الكلمات." or "⏸️ تم إيقاف فلتر الكلمات.")
end

-- ============================================================
-- [أوامر الإدارة]
-- ============================================================

-- طرد مستخدم
function Admin.kick(msg)
    local chat_id = msg.chat.id
    if not msg.reply_to_message then
        BotAPI.sendMessage(chat_id, "رد على رسالة المستخدم لطرده.")
        return
    end
    local target = msg.reply_to_message.from
    Security.kick_user(chat_id, target.id)
    BotAPI.sendMessage(chat_id, "🚫 تم طرد " .. (target.first_name or "المستخدم"))
end

-- حظر مستخدم
function Admin.ban(msg)
    local chat_id = msg.chat.id
    if not msg.reply_to_message then
        BotAPI.sendMessage(chat_id, "رد على رسالة المستخدم لحظره.")
        return
    end
    local target = msg.reply_to_message.from
    Security.ban_user(chat_id, target.id)
    BotAPI.sendMessage(chat_id, "🔨 تم حظر " .. (target.first_name or "المستخدم"))
end

-- إلغاء الحظر
function Admin.unban(msg, args)
    local chat_id = msg.chat.id
    if not args or args == "" then
        BotAPI.sendMessage(chat_id, "استخدم: /unban user_id")
        return
    end
    Security.unban_user(chat_id, tonumber(args))
    BotAPI.sendMessage(chat_id, "✅ تم إلغاء حظر المستخدم.")
end

-- كتم مستخدم
function Admin.mute(msg, args)
    local chat_id = msg.chat.id
    if not msg.reply_to_message then
        BotAPI.sendMessage(chat_id, "رد على رسالة المستخدم لكتمه.")
        return
    end
    local target = msg.reply_to_message.from
    local duration = tonumber(args) or 3600
    Security.mute_user(chat_id, target.id, duration)
    local mins = math.floor(duration / 60)
    BotAPI.sendMessage(chat_id, "🔇 تم كتم " .. (target.first_name or "المستخدم") .. " لمدة " .. mins .. " دقيقة.")
end

-- إلغاء الكتم
function Admin.unmute(msg)
    local chat_id = msg.chat.id
    if not msg.reply_to_message then
        BotAPI.sendMessage(chat_id, "رد على رسالة المستخدم لإلغاء كتمه.")
        return
    end
    local target = msg.reply_to_message.from
    Security.unmute_user(chat_id, target.id)
    BotAPI.sendMessage(chat_id, "✅ تم إلغاء كتم " .. (target.first_name or "المستخدم"))
end

-- تحذير مستخدم
function Admin.warn(msg, args)
    local chat_id = msg.chat.id
    if not msg.reply_to_message then
        BotAPI.sendMessage(chat_id, "رد على رسالة المستخدم لتحذيره.")
        return
    end
    local target = msg.reply_to_message.from
    local count = Security.warn_user(chat_id, target.id)
    if count >= Config.max_warnings then
        Security.kick_user(chat_id, target.id)
        Security.reset_warnings(chat_id, target.id)
        BotAPI.sendMessage(chat_id, "🚫 تم طرد " .. (target.first_name or "المستخدم") .. " بعد " .. Config.max_warnings .. " تحذيرات.")
    else
        local reason = args and " — " .. args or ""
        BotAPI.sendMessage(chat_id, "⚠️ تحذير " .. count .. "/" .. Config.max_warnings .. " لـ " .. (target.first_name or "المستخدم") .. reason)
    end
end

-- إزالة التحذيرات
function Admin.unwarn(msg)
    local chat_id = msg.chat.id
    if not msg.reply_to_message then
        BotAPI.sendMessage(chat_id, "رد على رسالة المستخدم لإزالة تحذيراته.")
        return
    end
    local target = msg.reply_to_message.from
    Security.reset_warnings(chat_id, target.id)
    BotAPI.sendMessage(chat_id, "✅ تم إزالة جميع تحذيرات " .. (target.first_name or "المستخدم"))
end

-- عرض التحذيرات
function Admin.warnings(msg)
    local chat_id = msg.chat.id
    local target = msg.reply_to_message and msg.reply_to_message.from or msg.from
    local count = Security.get_warnings(chat_id, target.id)
    BotAPI.sendMessage(chat_id, "⚠️ تحذيرات " .. (target.first_name or "المستخدم") .. ": " .. count .. "/" .. Config.max_warnings)
end

-- ============================================================
-- [أوامر الكلمات الممنوعة]
-- ============================================================

function Admin.add_bad_word(msg, args)
    if not args or args == "" then
        BotAPI.sendMessage(msg.chat.id, "استخدم: /addbadword كلمة")
        return
    end
    Security.add_bad_word(args)
    local words = Security.list_bad_words()
    BotAPI.sendMessage(msg.chat.id, "✅ تم إضافة '" .. args .. "' للكلمات الممنوعة.\nالمجموع: " .. #words .. " كلمة.")
end

function Admin.remove_bad_word(msg, args)
    if not args or args == "" then
        BotAPI.sendMessage(msg.chat.id, "استخدم: /delbadword كلمة")
        return
    end
    Security.remove_bad_word(args)
    BotAPI.sendMessage(msg.chat.id, "✅ تم حذف '" .. args .. "' من الكلمات الممنوعة.")
end

function Admin.list_bad_words(msg)
    local words = Security.list_bad_words()
    if not words or #words == 0 then
        BotAPI.sendMessage(msg.chat.id, "📋 لا توجد كلمات ممنوعة.")
        return
    end
    local list = {}
    for i, w in ipairs(words) do
        table.insert(list, i .. ". " .. w)
    end
    BotAPI.sendMessage(msg.chat.id, "📋 الكلمات الممنوعة (" .. #words .. "):\n\n" .. table.concat(list, "\n"))
end

function Admin.clear_bad_words(msg)
    Security.clear_bad_words()
    BotAPI.sendMessage(msg.chat.id, "✅ تم مسح جميع الكلمات الممنوعة.")
end

-- ============================================================
-- [أوامر القفل]
-- ============================================================

function Admin.lock_chat(msg)
    Security.lock_chat(msg.chat.id)
    BotAPI.sendMessage(msg.chat.id, "🔒 تم قفل المجموعة. فقط الأدمن يقدر يرسل.")
end

function Admin.unlock_chat(msg)
    Security.unlock_chat(msg.chat.id)
    BotAPI.sendMessage(msg.chat.id, "🔓 تم فتح المجموعة.")
end

-- ============================================================
-- [عرض الإعدادات]
-- ============================================================

function Admin.show_settings(msg)
    local chat_id = msg.chat.id
    local settings = Security.get_group_settings(chat_id)

    local function status(key)
        return settings[key] == "true" and "✅" or "❌"
    end

    local text = [[
⚙️ إعدادات المجموعة

🛡️ الحماية: ]] .. status("protection") .. "\n" ..
[[🚫 منع الروابط: ]] .. status("anti_link") .. "\n" ..
[[🌊 منع التكرار: ]] .. status("anti_flood") .. "\n" ..
[[🤖 منع البوتات: ]] .. status("anti_bot") .. "\n" ..
[[⚔️ منع الهجمات: ]] .. status("anti_raid") .. "\n" ..
[[🤬 فلتر الكلمات: ]] .. status("bad_words_filter") .. "\n" ..
[[👋 الترحيب: ]] .. status("welcome") .. "\n" ..
[[👋 المغادرة: ]] .. status("goodbye") .. "\n\n" ..
[[📋 الكلمات الممنوعة: ]] .. #Security.list_bad_words() .. " كلمة"

    BotAPI.sendMessage(chat_id, text)
end

-- ============================================================
-- [معلومات المجموعة]
-- ============================================================

function Admin.group_info(msg)
    local chat_id = msg.chat.id
    local res = BotAPI.request("getChat", {chat_id = chat_id})
    if not res or not res.ok then return end
    local chat = res.result
    local text = "📋 معلومات المجموعة\n\n"
    text = text .. "📝 الاسم: " .. (chat.title or "غير معروف") .. "\n"
    text = text .. "🆔 المعرف: " .. (chat.username or "لا يوجد") .. "\n"
    text = text .. "🔢 ID: " .. tostring(chat_id) .. "\n"
    text = text .. "👥 الأعضاء: " .. (chat.members_count or "غير معروف") .. "\n"
    text = text .. "📝 الوصف: " .. (chat.description or "لا يوجد") .. "\n"
    BotAPI.sendMessage(chat_id, text)
end

-- ============================================================
-- [ترقية/إزالة أدمن]
-- ============================================================

function Admin.promote(msg)
    local chat_id = msg.chat.id
    if not msg.reply_to_message then
        BotAPI.sendMessage(chat_id, "رد على رسالة المستخدم لترقيته.")
        return
    end
    local target = msg.reply_to_message.from
    BotAPI.request("promoteChatMember", {
        chat_id = chat_id,
        user_id = target.id,
        can_delete_messages = "true",
        can_restrict_members = "true",
        can_invite_users = "true",
        can_change_info = "false",
        can_pin_messages = "true",
    })
    BotAPI.sendMessage(chat_id, "👑 تم ترقية " .. (target.first_name or "المستخدم") .. " لأدمن.")
end

function Admin.demote(msg)
    local chat_id = msg.chat.id
    if not msg.reply_to_message then
        BotAPI.sendMessage(chat_id, "رد على رسالة المستخدم لإزالته من الأدمنية.")
        return
    end
    local target = msg.reply_to_message.from
    BotAPI.request("promoteChatMember", {
        chat_id = chat_id,
        user_id = target.id,
        can_delete_messages = "false",
        can_restrict_members = "false",
        can_invite_users = "false",
        can_change_info = "false",
        can_pin_messages = "false",
    })
    BotAPI.sendMessage(chat_id, "⬇️ تم إزالة " .. (target.first_name or "المستخدم") .. " من الأدمنية.")
end

-- ============================================================
-- [تثبيت رسالة]
-- ============================================================

function Admin.pin(msg)
    if not msg.reply_to_message then
        BotAPI.sendMessage(msg.chat.id, "رد على رسالة لتثبيتها.")
        return
    end
    BotAPI.request("pinChatMessage", {
        chat_id = msg.chat.id,
        message_id = msg.reply_to_message.message_id,
        disable_notification = "true",
    })
    BotAPI.sendMessage(msg.chat.id, "📌 تم تثبيت الرسالة.")
end

function Admin.unpin(msg)
    BotAPI.request("unpinAllChatMessages", {chat_id = msg.chat.id})
    BotAPI.sendMessage(msg.chat.id, "📌 تم إلغاء تثبيت جميع الرسائل.")
end

-- ============================================================
-- [تعيين/حذف الترحيب]
-- ============================================================

function Admin.set_welcome(msg, args)
    local chat_id = msg.chat.id
    if not args or args == "" then
        BotAPI.sendMessage(chat_id, "استخدم: /setwelcome نص الترحيب")
        return
    end
    Redis.set("welcome:" .. chat_id, args)
    BotAPI.sendMessage(chat_id, "✅ تم تعيين رسالة الترحيب.")
end

function Admin.set_goodbye(msg, args)
    local chat_id = msg.chat.id
    if not args or args == "" then
        BotAPI.sendMessage(chat_id, "استخدم: /setgoodbye نص المغادرة")
        return
    end
    Redis.set("goodbye:" .. chat_id, args)
    BotAPI.sendMessage(chat_id, "✅ تم تعيين رسالة المغادرة.")
end

-- ============================================================
-- [إيقاف الرسائل المؤقت]
-- ============================================================

function Admin.silence(msg, args)
    local chat_id = msg.chat.id
    local duration = tonumber(args) or 30
    Security.lock_chat(chat_id)
    BotAPI.sendMessage(chat_id, "🔇 تم إيقاف المجموعة لمدة " .. duration .. " دقيقة.")
    os.execute("sleep " .. (duration * 60))
    Security.unlock_chat(chat_id)
    BotAPI.sendMessage(chat_id, "🔊 تم إعادة فتح المجموعة.")
end

-- ============================================================
-- [مسح الرسائل]
-- ============================================================

function Admin.purge(msg)
    local chat_id = msg.chat.id
    if not msg.reply_to_message then
        BotAPI.sendMessage(chat_id, "رد على رسالة وسيتم حذف كل الرسائل من تلك الرسالة حتى الآن.")
        return
    end
    local start_id = msg.reply_to_message.message_id
    local current_id = msg.message_id
    local count = 0
    for id = start_id, current_id do
        BotAPI.request("deleteMessage", {chat_id = chat_id, message_id = id})
        count = count + 1
    end
    BotAPI.sendMessage(chat_id, "🗑️ تم مسح " .. count .. " رسالة.")
end

-- ============================================================
-- [جلب معلومات مستخدم]
-- ============================================================

function Admin.user_info(msg, args)
    local chat_id = msg.chat.id
    local target
    if msg.reply_to_message then
        target = msg.reply_to_message.from
    elseif args and args ~= "" then
        local res = BotAPI.request("getChatMember", {chat_id = chat_id, user_id = tonumber(args)})
        if res and res.ok then
            target = res.result.user
        end
    end
    if not target then
        BotAPI.sendMessage(chat_id, "رد على رسالة المستخدم أو استخدم: /info user_id")
        return
    end
    local warns = Security.get_warnings(chat_id, target.id)
    local text = "👤 معلومات المستخدم\n\n"
    text = text .. "📝 الاسم: " .. (target.first_name or "غير معروف") .. "\n"
    text = text .. "📝 الاسم الكامل: " .. ((target.first_name or "") .. " " .. (target.last_name or "")) .. "\n"
    text = text .. "🆔 المعرف: @" .. (target.username or "لا يوجد") .. "\n"
    text = text .. "🔢 ID: " .. tostring(target.id) .. "\n"
    text = text .. "🤖 بوت: " .. (target.is_bot and "نعم" or "لا") .. "\n"
    text = text .. "⚠️ تحذيرات: " .. warns .. "/" .. Config.max_warnings .. "\n"
    BotAPI.sendMessage(chat_id, text)
end

-- ============================================================
-- [قائمة الأوامر]
-- ============================================================

function Admin.help(msg)
    local text = [[
📋 أوامر الأدمن

🛡️ الحماية:
/حماية on|off - تفعيل/إيقاف الحماية
/antilink on|off - منع الروابط
/antiflood on|off - منع التكرار
/antibot on|off - منع البوتات
/antibadwords on|off - فلتر الكلمات
/lock - قفل المجموعة
/unlock - فتح المجموعة

👥 الإدارة:
/kick - طرد
/ban - حظر
/unban - إلغاء حظر
/mute - كتم (بالدقائق)
/unmute - إلغاء كتم
/warn - تحذير
/unwarn - إزالة تحذيرات
/warnings - عرض التحذيرات
/promote - ترقية أدمن
/demote - إزالة أدمن
/pin - تثبيت رسالة
/unpin - إلغاء تثبيت
/purge - مسح رسائل
/silence - إيقاف مؤقت (بالدقائق)

🤬 الكلمات الممنوعة:
/addbadword - إضافة كلمة
/delbadword - حذف كلمة
/badwords - عرض الكلمات
/clearbadwords - مسح الكل

ℹ️ معلومات:
/settings - إعدادات المجموعة
/info - معلومات مستخدم
/groupinfo - معلومات المجموعة
/setwelcome - تعيين ترحيب
/setgoodbye - تعيين مغادرة
]]
    BotAPI.sendMessage(msg.chat.id, text)
end

return Admin
