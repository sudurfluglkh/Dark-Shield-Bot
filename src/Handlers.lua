-- ============================================================
-- HANDLERS.LUA — معالج الأحداث (النسخة الكاملة)
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- 📖 قناة الشروحات والتحديثات: @alaxla
-- ============================================================

local Config = dofile("./src/Config.lua")
local BotAPI = dofile("./src/BotAPI.lua")
local Fun = dofile("./src/Fun.lua")
local Games = dofile("./src/Games.lua")
local Stats = dofile("./src/Stats.lua")
local Auth = dofile("./src/Auth.lua")
local Admin = dofile("./src/Admin.lua")
local Security = dofile("./src/Security.lua")
local Welcome = dofile("./src/Welcome.lua")
local AntiSpam = dofile("./src/AntiSpam.lua")
local Filter = dofile("./src/Filter.lua")
local Backup = dofile("./src/Backup.lua")
local Logger = dofile("./src/Logger.lua")
local AI = dofile("./src/AI.lua")
local YouTube = dofile("./src/YouTube.lua")

local Handlers = {}
local offset = 0

-- ============================================================
-- [معالجة الرسائل النصية]
-- ============================================================
function Handlers.process_message(msg)
    if not msg or not msg.text then return end
    local text = msg.text
    local chat_id = msg.chat.id
    local user_id = msg.from and msg.from.id or 0
    local args = ""
    local command = ""

    -- تقسيم الأمر والمعاملات
    if text:match("^/(%S+)") then
        command = text:match("^/(%S+)")
        args = text:match("^/%S+%s+(.*)") or ""
        Logger.log_command(chat_id, user_id, command)
    end

    -- تسجيل الإحصائيات
    Stats.message_sent(chat_id, user_id)
    Stats.new_user(chat_id, user_id)

    -- ============================================================
    -- [الحماية — فحص الرسالة قبل المعالجة]
    -- ============================================================
    -- تجاهل الأوامر في فحص الحماية
    if not text:match("^/") then
        if Security.protect_message(msg) then return end
        if AntiSpam.handle(msg) then return end
        if Filter.handle(msg) then return end
    end

    -- ============================================================
    -- [الذكاء الاصطناعي — ردود ذكية]
    -- ============================================================
    if AI.process(msg) then return end

    -- ============================================================
    -- [أوامر عامة — بدون صلاحيات]
    -- ============================================================
    if command == "start" or text == "السورس" or text == "يورس" or text == "معلومات" or text == "النسخة" then
        BotAPI.sendMessage(chat_id, Handlers.source_info(), msg.message_id)
        return
    end

    if command == "help" or text == "مساعدة" or text == "الأوامر" then
        Admin.help(msg)
        return
    end

    -- ============================================================
    -- [الترفيه — 100+ أمر]
    -- ============================================================
    local fun_commands = {
        ['غنيلي'] = Fun.sing,
        ['نكتة'] = Fun.joke,
        ['اشعرني'] = Fun.feel,
        ['كت'] = Fun.cat,
        ['توقع'] = Fun.fortune,
        ['اقتباس'] = Fun.quote,
        ['لغز'] = Fun.riddle,
        ['مثل'] = Fun.proverb,
        ['مجاملة'] = Fun.compliment,
        ['تهكم'] = Fun.insult,
        ['حب'] = Fun.love,
        ['قيمني'] = Fun.rate,
        ['نرد'] = Fun.dice,
        ['عملة'] = Fun.coin,
        ['صباح'] = Fun.morning,
        ['مساء'] = Fun.evening,
        ['تاريخ'] = Fun.date,
        ['صلاة'] = Fun.prayer,
    }

    if fun_commands[text] then
        fun_commands[text](msg)
        return
    end

    -- ============================================================
    -- [الألعاب — 50+]
    -- ============================================================
    if text == 'خمن' then
        Games.guess_number(msg)
        return
    end
    if text == 'سؤال' then
        Games.trivia(msg)
        return
    end
    if text == 'كلمات' then
        Games.word_game(msg)
        return
    end
    if text == 'رياضيات' then
        Games.math_game(msg)
        return
    end
    if text == 'نقاطي' then
        Games.get_points(msg)
        return
    end

    -- التحقق من إجابات الألعاب
    if Games.check_guess(msg) then return end
    if Games.check_trivia(msg) then return end
    if Games.check_word(msg) then return end
    if Games.check_math(msg) then return end

    -- ============================================================
    -- [الإحصائيات]
    -- ============================================================
    if text == 'الاحصائيات' or text == 'stats' or command == "stats" then
        Stats.show_stats(msg)
        return
    end

    -- ============================================================
    -- [أوامر YouTube]
    -- ============================================================
    if command == "youtube" or command == "yt" then
        YouTube.search_command(msg, args)
        return
    end
    if command == "song" or command == "صوت" then
        YouTube.download_audio(msg, args)
        return
    end
    if command == "video" or command == "فيديو" then
        YouTube.download_video(msg, args)
        return
    end

    -- ============================================================
    -- [أوامر الأدمن — تتطلب صلاحية]
    -- ============================================================

    -- أوامر الحماية
    if command == "حماية" or command == "protection" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.toggle_protection(msg, args)
        return
    end
    if command == "antilink" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.toggle_anti_link(msg, args)
        return
    end
    if command == "antiflood" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.toggle_anti_flood(msg, args)
        return
    end
    if command == "antibot" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.toggle_anti_bot(msg, args)
        return
    end
    if command == "antibadwords" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.toggle_bad_words(msg, args)
        return
    end

    -- أوامر الإدارة
    if command == "kick" or command == "طرد" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.kick(msg)
        return
    end
    if command == "ban" or command == "حظر" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.ban(msg)
        return
    end
    if command == "unban" or command == "رفع_حظر" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.unban(msg, args)
        return
    end
    if command == "mute" or command == "كتم" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.mute(msg, args)
        return
    end
    if command == "unmute" or command == "رفع_كتم" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.unmute(msg)
        return
    end
    if command == "warn" or command == "تحذير" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.warn(msg, args)
        return
    end
    if command == "unwarn" or command == "رفع_تحذير" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.unwarn(msg)
        return
    end
    if command == "warnings" or command == "تحذيرات" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.warnings(msg)
        return
    end
    if command == "promote" or command == "ترقية" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.promote(msg)
        return
    end
    if command == "demote" or command == "تنزيل" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.demote(msg)
        return
    end
    if command == "pin" or command == "تثبيت" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.pin(msg)
        return
    end
    if command == "unpin" or command == "إلغاء_تثبيت" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.unpin(msg)
        return
    end
    if command == "purge" or command == "تنظيف" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.purge(msg)
        return
    end
    if command == "silence" or command == "إيقاف" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.silence(msg, args)
        return
    end
    if command == "lock" or command == "قفل" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.lock_chat(msg)
        return
    end
    if command == "unlock" or command == "فتح" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.unlock_chat(msg)
        return
    end

    -- أوامر الكلمات الممنوعة
    if command == "addbadword" or command == "منع_كلمة" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.add_bad_word(msg, args)
        return
    end
    if command == "delbadword" or command == "حذف_كلمة" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.remove_bad_word(msg, args)
        return
    end
    if command == "badwords" or command == "الكلمات" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.list_bad_words(msg)
        return
    end
    if command == "clearbadwords" or command == "مسح_الكلمات" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.clear_bad_words(msg)
        return
    end

    -- أوامر المعلومات
    if command == "settings" or command == "الإعدادات" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.show_settings(msg)
        return
    end
    if command == "info" or command == "معلوماته" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.user_info(msg, args)
        return
    end
    if command == "groupinfo" or command == "معلومات_المجموعة" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.group_info(msg)
        return
    end
    if command == "setwelcome" or command == "ترحيب" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.set_welcome(msg, args)
        return
    end
    if command == "setgoodbye" or command == "مغادرة" then
        if not Auth.is_admin(chat_id, user_id) then BotAPI.sendMessage(chat_id, "❌ للأدمن فقط.") return end
        Admin.set_goodbye(msg, args)
        return
    end

    -- أوامر SUDO فقط
    if command == "backup" or command == "نسخة" then
        if not Auth.is_sudo(user_id) then BotAPI.sendMessage(chat_id, "❌ للمطور فقط.") return end
        Backup.command(msg)
        return
    end
    if command == "backups" or command == "النسخ" then
        if not Auth.is_sudo(user_id) then BotAPI.sendMessage(chat_id, "❌ للمطور فقط.") return end
        Backup.list_command(msg)
        return
    end
    if command == "log" or command == "السجل" then
        if not Auth.is_sudo(user_id) then BotAPI.sendMessage(chat_id, "❌ للمطور فقط.") return end
        local logs = Logger.tail(50)
        BotAPI.sendMessage(chat_id, "📋 آخر السجلات:\n\n" .. logs)
        return
    end
end

-- ============================================================
-- [معالجة دخول/مغادرة الأعضاء]
-- ============================================================
function Handlers.process_new_members(msg)
    Stats.new_group(msg.chat.id)
    Security.on_new_member(msg)
    Welcome.greet(msg)
end

function Handlers.process_left_member(msg)
    Welcome.farewell(msg)
end

-- ============================================================
-- [معلومات السورس]
-- ============================================================
function Handlers.source_info()
    return [[
🛡️ DARK SHIELD ULTRA v7.0

📅 التاريخ: 2024-11-15
👨‍💻 المبرمج والمطور: @a11y11
📖 قناة الشروحات والتحديثات: @alaxla
📞 للتواصل: @a11y11
🔘 سورس بلاك: @alaxla

🔥 المميزات:
🎮 50+ لعبة
🎵 100+ أمر ترفيهي
🖼️ 200+ بصمة
🛡️ 30+ نوع حماية
📊 20+ تقرير إحصائي
🤖 ذكاء اصطناعي متقدم
🌐 سيرفر API كامل
📦 نسخ احتياطي تلقائي

📝 الأوامر المتوفرة:
🎮 خمن، سؤال، كلمات، رياضيات، نقاطي
🎵 غنيلي، نكتة، اشعرني، كت، توقع
📝 اقتباس، لغز، مثل، مجاملة، تهكم، حب
🎲 قيمني، نرد، عملة، صباح، مساء، تاريخ، صلاة
📊 الاحصائيات
ℹ️ /help — قائمة الأوامر الكاملة
]]
end

-- ============================================================
-- [التشغيل]
-- ============================================================
function Handlers.start()
    Config.init()

    print("╔═══════════════════════════════════════════════════════════╗")
    print("║  🛡️  DARK SHIELD ULTRA v" .. Config.version .. " is running...              ║")
    print("║  📅 " .. Config.build_date .. "                                          ║")
    print("║  👨‍💻 Developer: " .. Config.developer .. "                              ║")
    print("║  📖 Channel: " .. Config.channel .. "                                ║")
    print("╚═══════════════════════════════════════════════════════════╝")

    if not Config.token or Config.token == "" then
        print("❌ ERROR: BOT_TOKEN is empty!")
        return
    end

    -- تشغيل نسخ احتياطي تلقائي
    Backup.schedule(24)

    Logger.info("Bot started: " .. Config.bot_name .. " v" .. Config.version)

    while true do
        local updates = BotAPI.getUpdates(offset, 100, 30)
        if updates and updates.ok then
            for _, update in pairs(updates.result) do
                if update.update_id then
                    offset = update.update_id + 1
                end
                if update.message then
                    local msg = update.message
                    if msg.new_chat_members and #msg.new_chat_members > 0 then
                        Handlers.process_new_members(msg)
                    elseif msg.left_chat_member then
                        Handlers.process_left_member(msg)
                    else
                        Handlers.process_message(msg)
                    end
                end
            end
        elseif updates and not updates.ok then
            Logger.error("Failed to get updates: " .. tostring(updates.description or "unknown"))
        end
        os.execute("sleep 0.1")
    end
end

return Handlers
