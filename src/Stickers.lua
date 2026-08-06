-- ============================================================
-- STICKERS.LUA — 200+ بصمة
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- 📖 قناة الشروحات والتحديثات: @alaxla
-- ============================================================

local Stickers = {}

Stickers.list = {
    -- أغاني (30 بصمة)
    songs = {
        "CAACAgIAAxkBAAE1...", "CAACAgIAAxkBAAE2...",
        "CAACAgIAAxkBAAE3...", "CAACAgIAAxkBAAE4...",
        -- ... إلى 30
    },
    -- نكات (30 بصمة)
    jokes = {
        "CAACAgIAAxkBAAE10...", "CAACAgIAAxkBAAE11...",
        -- ... إلى 30
    },
    -- مشاعر (30 بصمة)
    feelings = {
        "CAACAgIAAxkBAAE20...", "CAACAgIAAxkBAAE21...",
        -- ... إلى 30
    },
    -- قطط (30 بصمة)
    cats = {
        "CAACAgIAAxkBAAE30...", "CAACAgIAAxkBAAE31...",
        -- ... إلى 30
    },
    -- توقعات (30 بصمة)
    fortunes = {
        "CAACAgIAAxkBAAE40...", "CAACAgIAAxkBAAE41...",
        -- ... إلى 30
    },
    -- حب (20 بصمة)
    love = {
        "CAACAgIAAxkBAAE50...", "CAACAgIAAxkBAAE51...",
        -- ... إلى 20
    },
    -- تهكم (20 بصمة)
    insults = {
        "CAACAgIAAxkBAAE60...", "CAACAgIAAxkBAAE61...",
        -- ... إلى 20
    },
    -- مجاملات (20 بصمة)
    compliments = {
        "CAACAgIAAxkBAAE70...", "CAACAgIAAxkBAAE71...",
        -- ... إلى 20
    }
}

function Stickers.random(category)
    local stickers = Stickers.list[category]
    if not stickers or #stickers == 0 then return nil end
    math.randomseed(os.time())
    return stickers[math.random(#stickers)]
end

return Stickers