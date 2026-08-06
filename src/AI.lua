-- ============================================================
-- AI.LUA — نظام الذكاء الاصطناعي
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- 📖 قناة الشروحات والتحديثات: @alaxla
-- ============================================================

local Config = dofile("./src/Config.lua")
local BotAPI = dofile("./src/BotAPI.lua")
local Redis = dofile("./src/Redis.lua")
local Phrases = dofile("./src/Phrases.lua")
local Logger = dofile("./src/Logger.lua")

local AI = {}

-- ============================================================
-- [1. ردود ذكية]
-- ============================================================

-- قاموس ردود بسيط
local responses = {
    -- تحيات
    ["مرحبا"] = "أهلاً وسهلاً بك! 🌹",
    ["السلام"] = "وعليكم السلام ورحمة الله 🌟",
    ["هاي"] = "هاي! كيف حالك؟ 😊",
    ["هلا"] = "هلا فيك! 👋",
    ["صباح الخير"] = "صباح النور والفل! ☀️",
    ["مساء الخير"] = "مساء النور والورد! 🌙",

    -- أسئلة
    ["كيف حالك"] = "تمام والحمد لله، أنت كيفك؟ 😊",
    ["وش أخبارك"] = "كل شي تمام، شكراً لسؤالك! 🌟",
    ["من انت"] = "أنا Dark Shield Bot 🛡️، بوت حماية وألعاب!",
    ["اسمك"] = "اسمي Dark Shield 🛡️",
    ["منو انت"] = "أنا Dark Shield Bot 🛡️، صاحبك في الحماية والترفيه!",

    -- مشاعر
    ["حزين"] = "لا تحزن، كل شي بيصير خير 🌹",
    ["تعبان"] = "ارتاح شوي، تستاهل الراحة 💪",
    ["فرحان"] = "هذا اللي نبيه! 🎉 يلا فرحة مشتركة!",

    -- وداع
    ["باي"] = "مع السلامة! 🌹",
    ["وداعا"] = "في أمان الله! 👋",
    ["تصبح على خير"] = "وأنت بخير 🌙",

    -- شكر
    ["شكرا"] = "العفو، هذا واجبي! 🌟",
    ["مشكور"] = "لا شكر على واجب! 😊",
    ["تسلم"] = "يسلمك ربي! 🌹",
}

-- ============================================================
-- [2. مطابقة الردود]
-- ============================================================
function AI.find_response(text)
    if not text then return nil end
    local text_lower = text:lower()

    -- مطابقة مباشرة
    for pattern, response in pairs(responses) do
        if text:match(pattern) or text_lower:match(pattern:lower()) then
            return response
        end
    end

    -- مطابقة جزئية
    if text:match("سلام") then
        return "وعليكم السلام! 🌟"
    end
    if text:match("شكر") then
        return "العفو! 🌹"
    end
    if text:match("حب") then
        return "الحب كله! ❤️"
    end
    if text:match("ضحك") or text:match("هاها") then
        return "😂😂 ضحكتني!"
    end
    if text:match("؟") or text:match("?") then
        return "سؤال حلو! ما عندي جواب محدد بس... 🤔"
    end

    return nil
end

-- ============================================================
-- [3. التعلم الآلي البسيط]
-- ============================================================
function AI.learn(chat_id, user_id, text, response)
    local key = "ai:learn:" .. chat_id
    local data = text .. "|" .. response
    Redis.sadd(key, data)
    Logger.debug("AI learned: " .. text .. " -> " .. response)
end

-- ============================================================
-- [4. استرجاع ما تعلمه البوت]
-- ============================================================
function AI.get_learned(chat_id, text)
    local key = "ai:learn:" .. chat_id
    local learned = Redis.smembers(key)
    for _, item in ipairs(learned) do
        local pattern, response = item:match("^(.-)|(.+)$")
        if pattern and text:match(pattern) then
            return response
        end
    end
    return nil
end

-- ============================================================
-- [5. معالجة الرسالة الذكية]
-- ============================================================
function AI.process(msg)
    if not msg or not msg.text then return false end
    local text = msg.text

    -- تجاهل الأوامر
    if text:match("^/") then return false end

    -- 1. ابحث في ما تعلمه البوت
    local learned = AI.get_learned(msg.chat.id, text)
    if learned then
        BotAPI.sendMessage(msg.chat.id, learned, msg.message_id)
        return true
    end

    -- 2. ابحث في قاموس الردود
    local response = AI.find_response(text)
    if response then
        BotAPI.sendMessage(msg.chat.id, response, msg.message_id)
        return true
    end

    -- 3. رد عشوائي للرسائل غير المفهومة
    if math.random(1, 100) <= 10 then
        local random_responses = {
            "🤔interesting...",
            "مو فاهم عليك بالضبط، بس أنا معك!",
            "حدثني أكثر! 👀",
            "هههه تمام 👍",
            "حلو هذا! 🌟",
            "ما أعرف شنو أقول، بس أنا أسمعك! 👂",
        }
        BotAPI.sendMessage(msg.chat.id, random_responses[math.random(#random_responses)], msg.message_id)
        return true
    end

    return false
end

-- ============================================================
-- [6. توليد نص بسيط]
-- ============================================================
function AI.generate(text_type)
    if text_type == "joke" then
        return Phrases.random("./data/phrases/jokes.txt")
    elseif text_type == "quote" then
        return Phrases.random("./data/phrases/quotes.txt")
    elseif text_type == "fortune" then
        return Phrases.random("./data/phrases/fortunes.txt")
    end
    return nil
end

return AI
