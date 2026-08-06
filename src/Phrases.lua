-- ============================================================
-- PHRASES.LUA — نظام إدارة الكلايش
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- 📖 قناة الشروحات والتحديثات: @alaxla
-- ============================================================

local Phrases = {}

function Phrases.load(file_path)
    local file = io.open(file_path, "r")
    if not file then return {} end
    local content = file:read("*all")
    file:close()
    local lines = {}
    for line in content:gmatch("[^\r\n]+") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if line ~= "" and not line:match("^#") then
            table.insert(lines, line)
        end
    end
    return lines
end

function Phrases.save(file_path, phrases)
    local file = io.open(file_path, "w")
    if not file then return false end
    for _, phrase in pairs(phrases) do
        file:write(phrase .. "\n")
    end
    file:close()
    return true
end

function Phrases.add(file_path, phrase)
    if not phrase or phrase == "" then return false end
    local phrases = Phrases.load(file_path)
    table.insert(phrases, phrase)
    return Phrases.save(file_path, phrases)
end

function Phrases.random(file_path)
    local phrases = Phrases.load(file_path)
    if #phrases == 0 then return nil end
    math.randomseed(os.time())
    return phrases[math.random(#phrases)]
end

function Phrases.list(file_path)
    local phrases = Phrases.load(file_path)
    local result = ""
    for i, phrase in pairs(phrases) do
        result = result .. i .. ". " .. phrase .. "\n"
    end
    return result
end

return Phrases