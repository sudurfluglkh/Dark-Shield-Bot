-- ============================================================
-- FUN.LUA — 100+ أمر ترفيهي
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- 📖 قناة الشروحات والتحديثات: @alaxla
-- ============================================================

local BotAPI = dofile("./src/BotAPI.lua")
local Stickers = dofile("./src/Stickers.lua")
local Phrases = dofile("./src/Phrases.lua")

local Fun = {}

-- ============================================================
-- [الأغاني]
-- ============================================================
function Fun.sing(msg)
    local sticker = Stickers.random("songs")
    if sticker then
        BotAPI.request("sendSticker", {chat_id = msg.chat.id, sticker = sticker})
    end
    local song = Phrases.random("./data/phrases/songs.txt") or "🎵 يا ليل يا عين..."
    BotAPI.sendMessage(msg.chat.id, song, msg.message_id, 'Markdown')
end

-- ============================================================
-- [النكات]
-- ============================================================
function Fun.joke(msg)
    local sticker = Stickers.random("jokes")
    if sticker then
        BotAPI.request("sendSticker", {chat_id = msg.chat.id, sticker = sticker})
    end
    local joke = Phrases.random("./data/phrases/jokes.txt") or "😂 مرة واحد دخل مطعم..."
    BotAPI.sendMessage(msg.chat.id, joke, msg.message_id, 'Markdown')
end

-- ============================================================
-- [المشاعر]
-- ============================================================
function Fun.feel(msg)
    local sticker = Stickers.random("feelings")
    if sticker then
        BotAPI.request("sendSticker", {chat_id = msg.chat.id, sticker = sticker})
    end
    local feeling = Phrases.random("./data/phrases/feelings.txt") or "😊 سعيد"
    BotAPI.sendMessage(msg.chat.id, "💭 " .. feeling, msg.message_id, 'Markdown')
end

-- ============================================================
-- [القطط]
-- ============================================================
function Fun.cat(msg)
    local sticker = Stickers.random("cats")
    if sticker then
        BotAPI.request("sendSticker", {chat_id = msg.chat.id, sticker = sticker})
    end
    local fact = Phrases.random("./data/phrases/cat_facts.txt") or "🐱 القطط كائنات رائعة"
    BotAPI.sendMessage(msg.chat.id, "🐈 " .. fact, msg.message_id, 'Markdown')
end

-- ============================================================
-- [التوقعات]
-- ============================================================
function Fun.fortune(msg)
    local sticker = Stickers.random("fortunes")
    if sticker then
        BotAPI.request("sendSticker", {chat_id = msg.chat.id, sticker = sticker})
    end
    local fortune = Phrases.random("./data/phrases/fortunes.txt") or "🔮 سوف تحقق نجاحاً"
    BotAPI.sendMessage(msg.chat.id, "🔮 " .. fortune, msg.message_id, 'Markdown')
end

-- ============================================================
-- [الاقتباسات]
-- ============================================================
function Fun.quote(msg)
    local quote = Phrases.random("./data/phrases/quotes.txt") or "💭 الحياة جميلة"
    BotAPI.sendMessage(msg.chat.id, "📝 " .. quote, msg.message_id, 'Markdown')
end

-- ============================================================
-- [الألغاز]
-- ============================================================
function Fun.riddle(msg)
    local riddle = Phrases.random("./data/phrases/riddles.txt") or "❓ ما هو الشيء الذي..."
    BotAPI.sendMessage(msg.chat.id, "🧩 " .. riddle, msg.message_id, 'Markdown')
end

-- ============================================================
-- [الأمثال]
-- ============================================================
function Fun.proverb(msg)
    local proverb = Phrases.random("./data/phrases/proverbs.txt") or "📜 الصبر مفتاح الفرج"
    BotAPI.sendMessage(msg.chat.id, "📜 " .. proverb, msg.message_id, 'Markdown')
end

-- ============================================================
-- [المجاملات]
-- ============================================================
function Fun.compliment(msg)
    local compliment = Phrases.random("./data/phrases/compliments.txt") or "💖 أنت رائع"
    local sticker = Stickers.random("compliments")
    if sticker then
        BotAPI.request("sendSticker", {chat_id = msg.chat.id, sticker = sticker})
    end
    BotAPI.sendMessage(msg.chat.id, "💖 " .. compliment, msg.message_id, 'Markdown')
end

-- ============================================================
-- [التهكمات]
-- ============================================================
function Fun.insult(msg)
    local insult = Phrases.random("./data/phrases/insults.txt") or "😒 كفاية"
    local sticker = Stickers.random("insults")
    if sticker then
        BotAPI.request("sendSticker", {chat_id = msg.chat.id, sticker = sticker})
    end
    BotAPI.sendMessage(msg.chat.id, "😒 " .. insult, msg.message_id, 'Markdown')
end

-- ============================================================
-- [رسائل حب]
-- ============================================================
function Fun.love(msg)
    local love = Phrases.random("./data/phrases/love.txt") or "❤️ أحبك"
    local sticker = Stickers.random("love")
    if sticker then
        BotAPI.request("sendSticker", {chat_id = msg.chat.id, sticker = sticker})
    end
    BotAPI.sendMessage(msg.chat.id, "❤️ " .. love, msg.message_id, 'Markdown')
end

-- ============================================================
-- [تقييم]
-- ============================================================
function Fun.rate(msg)
    local rate = math.random(1, 10)
    local user = msg.from.first_name or "المستخدم"
    BotAPI.sendMessage(msg.chat.id, "⭐ *تقييم " .. user .. "*\n📊 " .. rate .. "/10", msg.message_id, 'Markdown')
end

-- ============================================================
-- [نرد]
-- ============================================================
function Fun.dice(msg)
    local dice = math.random(1, 6)
    BotAPI.sendMessage(msg.chat.id, "🎲 *ظهر الرقم:* " .. dice, msg.message_id, 'Markdown')
end

-- ============================================================
-- [عملة]
-- ============================================================
function Fun.coin(msg)
    local coin = math.random(1, 2) == 1 and "🪙 *وجه*" or "🪙 *كتف*"
    BotAPI.sendMessage(msg.chat.id, coin, msg.message_id, 'Markdown')
end

-- ============================================================
-- [تحية الصباح]
-- ============================================================
function Fun.morning(msg)
    local greetings = {"🌅 صباح الخير", "☀️ صباح النور", "🌤️ صباح الورد", "🌄 صباح الفل"}
    BotAPI.sendMessage(msg.chat.id, greetings[math.random(#greetings)], msg.message_id, 'Markdown')
end

-- ============================================================
-- [تحية المساء]
-- ============================================================
function Fun.evening(msg)
    local greetings = {"🌆 مساء الخير", "🌙 مساء النور", "🌃 مساء الورد", "🌌 مساء الفل"}
    BotAPI.sendMessage(msg.chat.id, greetings[math.random(#greetings)], msg.message_id, 'Markdown')
end

-- ============================================================
-- [تاريخ اليوم]
-- ============================================================
function Fun.date(msg)
    local date = os.date("%Y-%m-%d %H:%M:%S")
    BotAPI.sendMessage(msg.chat.id, "📅 *التاريخ:* " .. date, msg.message_id, 'Markdown')
end

-- ============================================================
-- [وقت الصلاة]
-- ============================================================
function Fun.prayer(msg)
    local prayers = {"🕌 الفجر", "🕌 الظهر", "🕌 العصر", "🕌 المغرب", "🕌 العشاء"}
    local prayer = prayers[math.random(#prayers)]
    BotAPI.sendMessage(msg.chat.id, "🕋 *وقت الصلاة:* " .. prayer, msg.message_id, 'Markdown')
end

return Fun