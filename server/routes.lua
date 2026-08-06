-- ============================================================
-- ROUTES.LUA — مسارات الـ API
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local Config = dofile("./src/Config.lua")
local Redis = dofile("./src/Redis.lua")
local Logger = dofile("./src/Logger.lua")

local Routes = {}

-- JSON بسيط
local function json_response(data)
    -- تحويل بسيط لـ JSON
    if type(data) == "table" then
        local parts = {}
        for k, v in pairs(data) do
            if type(v) == "string" then
                table.insert(parts, '"' .. k .. '": "' .. v .. '"')
            elseif type(v) == "number" then
                table.insert(parts, '"' .. k .. '": ' .. tostring(v))
            elseif type(v) == "boolean" then
                table.insert(parts, '"' .. k .. '": ' .. tostring(v))
            end
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    end
    return tostring(data or "")
end

function Routes.handle(method, path, body, headers)
    -- GET /api/status
    if method == "GET" and path == "/api/status" then
        return json_response({
            status = "online",
            bot_name = Config.bot_name,
            version = Config.version,
            timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        })
    end

    -- GET /api/stats
    if method == "GET" and path == "/api/stats" then
        local messages = tonumber(Redis.get("stats:messages:total") or "0")
        local users = tonumber(Redis.get("stats:users:total") or "0")
        local groups = tonumber(Redis.get("stats:groups:total") or "0")
        return json_response({
            messages = messages,
            users = users,
            groups = groups,
        })
    end

    -- GET /api/groups
    if method == "GET" and path == "/api/groups" then
        local groups = Redis.smembers("groups")
        return json_response({ groups = tostring(#groups) })
    end

    -- 404
    return json_response({
        error = "Not Found",
        path = path,
        method = method,
    })
end

return Routes
