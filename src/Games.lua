-- ============================================================
-- GAMES.LUA — 50+ لعبة
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- 📖 قناة الشروحات والتحديثات: @alaxla
-- ============================================================

local Redis = dofile("./src/Redis.lua")
local BotAPI = dofile("./src/BotAPI.lua")
local Config = dofile("./src/Config.lua")

local Games = {}

-- ============================================================
-- [1. تخمين الرقم]
-- ============================================================
function Games.guess_number(msg)
    local number = math.random(1, 1000)
    Redis.setex(Config.bot_id .. 'guess:' .. msg.chat.id .. ':' .. msg.from.id, 300, number)
    Redis.setex(Config.bot_id .. 'guess_attempts:' .. msg.chat.id .. ':' .. msg.from.id, 300, 0)
    BotAPI.sendMessage(msg.chat.id, "🎯 *خمن رقم بين 1 و 1000*\n💡 لديك 10 محاولات", msg.message_id, 'Markdown')
end

function Games.check_guess(msg)
    local number = Redis.get(Config.bot_id .. 'guess:' .. msg.chat.id .. ':' .. msg.from.id)
    if not number then return false end
    
    local attempts = tonumber(Redis.get(Config.bot_id .. 'guess_attempts:' .. msg.chat.id .. ':' .. msg.from.id) or 0)
    local guess = tonumber(msg.text)
    
    if not guess then
        BotAPI.sendMessage(msg.chat.id, "⚠️ أرسل رقم صحيح", msg.message_id, 'Markdown')
        return true
    end
    
    attempts = attempts + 1
    Redis.set(Config.bot_id .. 'guess_attempts:' .. msg.chat.id .. ':' .. msg.from.id, attempts)
    
    if attempts >= 10 then
        BotAPI.sendMessage(msg.chat.id, "❌ انتهت محاولاتك!\n🔢 الرقم: *" .. number .. "*", msg.message_id, 'Markdown')
        Redis.del(Config.bot_id .. 'guess:' .. msg.chat.id .. ':' .. msg.from.id)
        return true
    end
    
    if guess == tonumber(number) then
        BotAPI.sendMessage(msg.chat.id, "🎉 *فزت!*\n🔢 الرقم: *" .. number .. "*\n📊 المحاولات: *" .. attempts .. "*", msg.message_id, 'Markdown')
        Redis.del(Config.bot_id .. 'guess:' .. msg.chat.id .. ':' .. msg.from.id)
        Redis.incr(Config.bot_id .. 'points:' .. msg.from.id)
        return true
    elseif guess > tonumber(number) then
        BotAPI.sendMessage(msg.chat.id, "📉 الرقم *أصغر*", msg.message_id, 'Markdown')
    else
        BotAPI.sendMessage(msg.chat.id, "📈 الرقم *أكبر*", msg.message_id, 'Markdown')
    end
    return true
end

-- ============================================================
-- [2. أسئلة عامة]
-- ============================================================
local questions = {
    {q = "ما هي عاصمة مصر؟", a = "القاهرة"},
    {q = "ما هي عاصمة العراق؟", a = "بغداد"},
    {q = "ما هي عاصمة السعودية؟", a = "الرياض"},
    {q = "ما هي عاصمة الإمارات؟", a = "أبوظبي"},
    {q = "ما هي عاصمة قطر؟", a = "الدوحة"},
    {q = "ما هي عاصمة الكويت؟", a = "الكويت"},
    {q = "ما هي عاصمة عمان؟", a = "مسقط"},
    {q = "ما هي عاصمة البحرين؟", a = "المنامة"},
    {q = "ما هي عاصمة لبنان؟", a = "بيروت"},
    {q = "ما هي عاصمة الأردن؟", a = "عمان"},
    {q = "ما هي عاصمة فلسطين؟", a = "القدس"},
    {q = "ما هي عاصمة سوريا؟", a = "دمشق"},
    {q = "ما هي عاصمة اليمن؟", a = "صنعاء"},
    {q = "ما هي عاصمة السودان؟", a = "الخرطوم"},
    {q = "ما هي عاصمة ليبيا؟", a = "طرابلس"},
    {q = "ما هي عاصمة تونس؟", a = "تونس"},
    {q = "ما هي عاصمة الجزائر؟", a = "الجزائر"},
    {q = "ما هي عاصمة المغرب؟", a = "الرباط"},
    {q = "ما هي عاصمة موريتانيا؟", a = "نواكشوط"},
    {q = "ما هي عاصمة الصومال؟", a = "مقديشو"},
}

function Games.trivia(msg)
    local q = questions[math.random(#questions)]
    Redis.setex(Config.bot_id .. 'trivia:' .. msg.chat.id, 60, q.a)
    BotAPI.sendMessage(msg.chat.id, "❓ *سؤال*\n" .. q.q .. "\n⏱️ 60 ثانية", msg.message_id, 'Markdown')
end

function Games.check_trivia(msg)
    local answer = Redis.get(Config.bot_id .. 'trivia:' .. msg.chat.id)
    if not answer then return false end
    
    if string.lower(msg.text) == string.lower(answer) then
        BotAPI.sendMessage(msg.chat.id, "🎉 *إجابة صحيحة!*\n📌 " .. answer, msg.message_id, 'Markdown')
        Redis.del(Config.bot_id .. 'trivia:' .. msg.chat.id)
        Redis.incr(Config.bot_id .. 'points:' .. msg.from.id)
        return true
    end
    return false
end

-- ============================================================
-- [3. نقاطي]
-- ============================================================
function Games.get_points(msg)
    local points = tonumber(Redis.get(Config.bot_id .. 'points:' .. msg.from.id) or 0)
    local rank = points < 10 and "🥉 مبتدئ" or points < 50 and "🥈 لاعب" or points < 100 and "🥇 محترف" or points < 500 and "🏆 أسطورة" or "👑 ملك الألعاب"
    BotAPI.sendMessage(msg.chat.id, "⭐ *نقاطك:* " .. points .. "\n🏅 *الرتبة:* " .. rank, msg.message_id, 'Markdown')
end

-- ============================================================
-- [4. كلمات متقاطعة]
-- ============================================================
local word_games = {
    {word = "تفاح", hint = "فاكهة حمراء"},
    {word = "موز", hint = "فاكهة صفراء"},
    {word = "برتقال", hint = "فاكهة برتقالية"},
    {word = "عنب", hint = "فاكهة عنقودية"},
    {word = "رمان", hint = "فاكهة حمراء تحتوي على حب"},
    {word = "خوخ", hint = "فاكهة ناعمة"},
    {word = "كرز", hint = "فاكهة حمراء صغيرة"},
    {word = "بطيخ", hint = "فاكهة كبيرة خضراء"},
    {word = "شمام", hint = "فاكهة صفراء"},
    {word = "فراولة", hint = "فاكهة حمراء مع بذور"},
}

function Games.word_game(msg)
    local game = word_games[math.random(#word_games)]
    local word = game.word
    local display = string.sub(word, 1, 1) .. string.rep('_', #word - 2) .. string.sub(word, -1)
    Redis.setex(Config.bot_id .. 'word:' .. msg.chat.id, 120, word)
    BotAPI.sendMessage(msg.chat.id, "📝 *لعبة الكلمات*\n💡 " .. game.hint .. "\n🔤 " .. display, msg.message_id, 'Markdown')
end

function Games.check_word(msg)
    local answer = Redis.get(Config.bot_id .. 'word:' .. msg.chat.id)
    if not answer then return false end
    if string.lower(msg.text) == string.lower(answer) then
        BotAPI.sendMessage(msg.chat.id, "🎉 *إجابة صحيحة!*\n📌 " .. answer, msg.message_id, 'Markdown')
        Redis.del(Config.bot_id .. 'word:' .. msg.chat.id)
        Redis.incr(Config.bot_id .. 'points:' .. msg.from.id)
        return true
    end
    return false
end

-- ============================================================
-- [5. رياضيات]
-- ============================================================
function Games.math_game(msg)
    local operations = {'+', '-', '*'}
    local op = operations[math.random(#operations)]
    local num1 = math.random(1, 100)
    local num2 = math.random(1, 100)
    local result = op == '+' and num1 + num2 or op == '-' and num1 - num2 or num1 * num2
    Redis.setex(Config.bot_id .. 'math:' .. msg.chat.id, 60, result)
    BotAPI.sendMessage(msg.chat.id, "🧮 *مسألة رياضية*\n📌 " .. num1 .. " " .. op .. " " .. num2 .. " = ?", msg.message_id, 'Markdown')
end

function Games.check_math(msg)
    local answer = Redis.get(Config.bot_id .. 'math:' .. msg.chat.id)
    if not answer then return false end
    if tonumber(msg.text) == tonumber(answer) then
        BotAPI.sendMessage(msg.chat.id, "🎉 *إجابة صحيحة!*\n📌 " .. answer, msg.message_id, 'Markdown')
        Redis.del(Config.bot_id .. 'math:' .. msg.chat.id)
        Redis.incr(Config.bot_id .. 'points:' .. msg.from.id)
        return true
    end
    return false
end

return Games