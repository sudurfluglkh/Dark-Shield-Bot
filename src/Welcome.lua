-- ============================================================
-- WELCOME.LUA — نظام الترحيب والمغادرة
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local Config = dofile("./src/Config.lua")
local BotAPI = dofile("./src/BotAPI.lua")
local Redis = dofile("./src/Redis.lua")
local Security = dofile("./src/Security.lua")
local Utils = dofile("./src/Utils.lua")

local Welcome = {}

-- ============================================================
-- [الترحيب]
-- ============================================================
function Welcome.greet(msg)
    local chat_id = msg.chat.id
    local settings = Security.get_group_settings(chat_id)

    if settings.welcome ~= "true" then return end

    for _, member in ipairs(msg.new_chat_members or {}) do
        -- لا ترحب بالبوتات
        if not member.is_bot then
            local custom = Redis.get("welcome:" .. chat_id)
            local name = Utils.full_name(member)
            local mention = Utils.mention(member)
            local group_name = msg.chat.title or "المجموعة"

            local text
            if custom and custom ~= "" then
                -- استبدال المتغيرات
                text = custom
                text = text:gsub("{name}", mention)
                text = text:gsub("{first}", member.first_name or "")
                text = text:gsub("{group}", group_name)
                text = text:gsub("{id}", tostring(member.id))
            else
                text = "👋 أهلاً بك " .. mention .. " في " .. group_name .. "!\n"
                text = text .. "نتمنى لك إقامة ممتعة 🌹"
            end

            BotAPI.sendMessage(chat_id, text)
        end
    end
end

-- ============================================================
-- [المغادرة]
-- ============================================================
function Welcome.farewell(msg)
    local chat_id = msg.chat.id
    local settings = Security.get_group_settings(chat_id)

    if settings.goodbye ~= "true" then return end

    local member = msg.left_chat_member
    if not member then return end

    if member.is_bot then return end

    local custom = Redis.get("goodbye:" .. chat_id)
    local name = Utils.full_name(member)
    local mention = Utils.mention(member)
    local group_name = msg.chat.title or "المجموعة"

    local text
    if custom and custom ~= "" then
        text = custom
        text = text:gsub("{name}", mention)
        text = text:gsub("{first}", member.first_name or "")
        text = text:gsub("{group}", group_name)
        text = text:gsub("{id}", tostring(member.id))
    else
        text = "👋 وداعاً " .. mention .. "\nنسأل الله لك التوفيق 🌹"
    end

    BotAPI.sendMessage(chat_id, text)
end

return Welcome
