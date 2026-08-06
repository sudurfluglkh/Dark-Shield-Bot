-- ============================================================
-- BOTAPI.LUA — دوال تيليجرام
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- 📖 قناة الشروحات والتحديثات: @alaxla
-- ============================================================

local https = require("ssl.https")
local URL = require("socket.url")
local Config = dofile("./src/Config.lua")

-- JSON بسيط مدمج
local JSON = {}
function JSON.encode(val)
    if type(val) == "string" then
        return '"' .. val:gsub('"', '\\"'):gsub('\n', '\\n') .. '"'
    elseif type(val) == "number" then
        return tostring(val)
    elseif type(val) == "boolean" then
        return val and "true" or "false"
    elseif type(val) == "table" then
        local parts = {}
        for k, v in pairs(val) do
            if type(k) == "number" then
                table.insert(parts, JSON.encode(v))
            else
                table.insert(parts, '"' .. k .. '": ' .. JSON.encode(v))
            end
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    end
    return "null"
end

function JSON.decode(str)
    -- JSON decode بسيط
    if not str or str == "" then return nil end
    local fn = load("return " .. str:gsub('\\/', '/'))
    if fn then
        local ok, result = pcall(fn)
        if ok then return result end
    end
    return nil
end

-- محاولة استخدام dkjson إذا متوفر
local ok, dkjson = pcall(require, "dkjson")
if ok and dkjson then
    JSON = dkjson
end

local BotAPI = {}

function BotAPI.request(method, params)
    if not Config.token or Config.token == "" then
        return nil
    end
    local url = "https://api.telegram.org/bot" .. Config.token .. "/" .. method
    if params then
        local query = {}
        for k, v in pairs(params) do
            if type(v) == "table" then
                v = JSON.encode(v)
            end
            table.insert(query, k .. "=" .. URL.escape(tostring(v)))
        end
        url = url .. "?" .. table.concat(query, "&")
    end
    local res, code = https.request(url)
    if code ~= 200 then return nil end
    local ok, data = pcall(JSON.decode, res)
    if not ok then return nil end
    return data
end

function BotAPI.sendMessage(chat_id, text, reply_to_message_id, parse_mode)
    if not chat_id or not text then return nil end
    local params = {
        chat_id = chat_id,
        text = text,
        reply_to_message_id = reply_to_message_id or 0,
        disable_web_page_preview = true
    }
    if parse_mode then
        params.parse_mode = parse_mode
    end
    return BotAPI.request("sendMessage", params)
end

function BotAPI.getUpdates(offset, limit, timeout)
    return BotAPI.request("getUpdates", {
        offset = offset or 0,
        limit = limit or 100,
        timeout = timeout or 30,
        allowed_updates = JSON.encode({"message", "edited_message"})
    })
end

return BotAPI
