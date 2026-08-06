-- ============================================================
-- WS.LUA — WebSocket Server
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local socket = require("socket")
local Config = dofile("./src/Config.lua")
local Logger = dofile("./src/Logger.lua")

local WS = {}

function WS.start(host, port)
    host = host or "0.0.0.0"
    port = port or 8081

    local server = socket.bind(host, port)
    if not server then
        Logger.error("Failed to start WebSocket on " .. host .. ":" .. port)
        return
    end

    server:settimeout(1)
    Logger.info("WebSocket Server running on " .. host .. ":" .. port)
    print("🔌 WebSocket: ws://" .. host .. ":" .. port)

    local clients = {}

    while true do
        local client = server:accept()
        if client then
            client:settimeout(5)
            -- WebSocket handshake
            local request = client:receive("*l")
            if request and request:match("Upgrade: websocket") then
                -- قراءة الـ headers
                local key = ""
                local line = client:receive("*l")
                while line and line ~= "" do
                    if line:match("Sec-WebSocket-Key:") then
                        key = line:match("Sec-WebSocket-Key:%s*(.+)")
                    end
                    line = client:receive("*l")
                end
                -- إرسال handshake response (مبسط)
                client:send("HTTP/1.1 101 Switching Protocols\r\n")
                client:send("Upgrade: websocket\r\n")
                client:send("Connection: Upgrade\r\n")
                client:send("\r\n")
                table.insert(clients, client)
                Logger.info("WebSocket client connected")
            end
        end
    end
end

return WS
