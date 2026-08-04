-- ============================================================
-- HANDLERS.LUA — معالج الأحداث (النسخة الأقوى)
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

local Handlers = {}
local offset = 0

function Handlers.process_message(msg)
    if not msg or not msg.text then return end
    local text = msg.text
    local chat_id = msg.chat.id
    
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
    
    -- ============================================================
    -- [الإحصائيات]
    -- ============================================================
    if text == 'الاحصائيات' or text == 'stats' then
        Stats.show_stats(msg)
        return
    end
    
    -- ============================================================
    -- [السورس — الأقوى على الإطلاق]
    -- ============================================================
    if text == 'السورس' or text == 'يورس' or text == 'معلومات' or text == 'العمدة' or text == 'النسخة' then
        BotAPI.sendMessage(chat_id, [[
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║   ██████╗  █████╗ ██████╗ ██╗  ██╗                              ║
║   ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝                              ║
║   ██║  ██║███████║██████╔╝█████╔╝                               ║
║   ██║  ██║██╔══██║██╔══██╗██╔═██╗                               ║
║   ██████╔╝██║  ██║██║  ██║██║  ██╗                              ║
║   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝                              ║
║                                                                   ║
║   ███████╗██╗  ██╗██╗███████╗██╗     ██████╗                    ║
║   ██╔════╝██║  ██║██║██╔════╝██║     ██╔══██╗                   ║
║   ███████╗███████║██║█████╗  ██║     ██║  ██║                   ║
║   ╚════██║██╔══██║██║██╔══╝  ██║     ██║  ██║                   ║
║   ███████║██║  ██║██║███████╗███████╗██████╔╝                   ║
║   ╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═════╝                    ║
║                                                                   ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║   🚀 DARK SHIELD ULTRA v7.0                                      ║
║   📅 التاريخ: 2024-11-15                                         ║
║   👨‍💻 المبرمج والمطور: @a11y11                                    ║
║   📖 قناة الشروحات والتحديثات: @alaxla                           ║
║   📞 للتواصل: @a11y11                                            ║
║   🔘 سورس بلاك @alaxla                                            ║
║                                                                   ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║   🔥 المميزات:                                                   ║
║   🎮 50+ لعبة                                                   ║
║   🎵 100+ أمر ترفيهي                                            ║
║   🖼️ 200+ بصمة                                                 ║
║   🛡️ 30+ نوع حماية                                             ║
║   📊 20+ تقرير إحصائي                                           ║
║   🤖 ذكاء اصطناعي متقدم                                         ║
║   🌐 سيرفر API كامل                                             ║
║   📦 نسخ احتياطي تلقائي                                         ║
║   🔔 إشعارات ترحيب ومغادرة                                     ║
║                                                                   ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║   📝 الأوامر المتوفرة:                                           ║
║   🎮 خمن، سؤال، كلمات، رياضيات، نقاطي                           ║
║   🎵 غنيلي، نكتة، اشعرني، كت، توقع                              ║
║   📝 اقتباس، لغز، مثل، مجاملة، تهكم، حب                         ║
║   🎲 قيمني، نرد، عملة، صباح، مساء، تاريخ، صلاة                  ║
║   📊 الاحصائيات                                                  ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
]], msg.message_id, 'Markdown')
        return
    end
    
    -- التحقق من إجابات الألعاب
    if Games.check_guess(msg) then return end
    if Games.check_trivia(msg) then return end
    if Games.check_word(msg) then return end
    if Games.check_math(msg) then return end
end

function Handlers.start()
    print('╔═══════════════════════════════════════════════════════════════════╗')
    print('║                                                                   ║')
    print('║   🚀 DARK SHIELD ULTRA v7.0 is running...                       ║')
    print('║   📅 التاريخ: 2024-11-15                                         ║')
    print('║   👨‍💻 المبرمج والمطور: @a11y11                                    ║')
    print('║   📖 قناة الشروحات والتحديثات: @alaxla                           ║')
    print('║                                                                   ║')
    print('╚═══════════════════════════════════════════════════════════════════╝')
    
    if not Config.token or Config.token == "" then
        print('❌ ERROR: BOT_TOKEN is empty!')
        return
    end
    
    while true do
        local updates = BotAPI.getUpdates(offset, 100, 30)
        if updates and updates.ok then
            for _, update in pairs(updates.result) do
                if update.update_id then
                    offset = update.update_id + 1
                end
                if update.message then
                    Handlers.process_message(update.message)
                end
            end
        end
        os.execute('sleep 0.1')
    end
end

return Handlers