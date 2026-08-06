-- ============================================================
-- SERVER.LUA — سيرفر API
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local socket = require("socket")
local Config = dofile("./src/Config.lua")
local Routes = dofile("./server/routes.lua")
local Logger = dofile("./src/Logger.lua")

local Server = {}

function Server.start(host, port)
    host = host or "0.0.0.0"
    port = port or 8080

    local server = socket.bind(host, port)
    if not server then
        Logger.error("Failed to start server on " .. host .. ":" .. port)
        return
    end

    server:settimeout(1)
    Logger.info("API Server running on " .. host .. ":" .. port)
    print("🌐 API Server: http://" .. host .. ":" .. port)

    while true do
        local client = server:accept()
        if client then
            client:settimeout(5)
            local request = client:receive("*l")
            if request then
                local method, path = request:match("^(%u+)%s+(%S+)")
                -- قراءة الـ headers
                local headers = {}
                local line = client:receive("*l")
                while line and line ~= "" do
                    local key, value = line:match("^(.-):%s*(.+)$")
                    if key then headers[key] = value end
                    line = client:receive("*l")
                end
                -- قراءة الـ body
                local body = ""
                local content_length = tonumber(headers["Content-Length"] or "0")
                if content_length > 0 then
                    body = client:receive(content_length)
                end
                -- معالجة الطلب
                local response = Routes.handle(method, path, body, headers)
                client:send("HTTP/1.1 200 OK\r\n")
                client:send("Content-Type: application/json\r\n")
                client:send("Access-Control-Allow-Origin: *\r\n")
                client:send("Content-Length: " .. #response .. "\r\n")
                client:send("\r\n")
                client:send(response)
            end
            client:close()
        end
    end
end

return Server
