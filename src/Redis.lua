-- ============================================================
-- REDIS.LUA — الاتصال بـ Redis
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local redis = require("resty.redis")
local Config = dofile("./src/Config.lua")

local Redis = {}
local client = nil

function Redis.connect()
    if client then return client end
    client = redis:new()
    client:set_timeout(Config.timeout * 1000)
    local ok, err = client:connect(Config.redis_host, Config.redis_port)
    if not ok then
        print("[Redis] Connection failed: " .. tostring(err))
        return nil
    end
    if Config.redis_db and Config.redis_db > 0 then
        client:select(Config.redis_db)
    end
    print("[Redis] Connected to " .. Config.redis_host .. ":" .. Config.redis_port)
    return client
end

function Redis.key(k)
    return Config.prefix .. k
end

function Redis.get(key)
    local c = Redis.connect()
    if not c then return nil end
    local res, err = c:get(Redis.key(key))
    if not res then return nil end
    return res
end

function Redis.set(key, value)
    local c = Redis.connect()
    if not c then return false end
    local ok = c:set(Redis.key(key), value)
    return ok == "OK"
end

function Redis.setex(key, ttl, value)
    local c = Redis.connect()
    if not c then return false end
    local ok = c:setex(Redis.key(key), ttl, value)
    return ok == "OK"
end

function Redis.del(key)
    local c = Redis.connect()
    if not c then return false end
    c:del(Redis.key(key))
    return true
end

function Redis.incr(key)
    local c = Redis.connect()
    if not c then return 0 end
    return tonumber(c:incr(Redis.key(key))) or 0
end

function Redis.decr(key)
    local c = Redis.connect()
    if not c then return 0 end
    return tonumber(c:decr(Redis.key(key))) or 0
end

function Redis.hset(key, field, value)
    local c = Redis.connect()
    if not c then return false end
    return c:hset(Redis.key(key), field, value)
end

function Redis.hget(key, field)
    local c = Redis.connect()
    if not c then return nil end
    return c:hget(Redis.key(key), field)
end

function Redis.hgetall(key)
    local c = Redis.connect()
    if not c then return {} end
    return c:hgetall(Redis.key(key))
end

function Redis.hdel(key, field)
    local c = Redis.connect()
    if not c then return false end
    c:hdel(Redis.key(key), field)
    return true
end

function Redis.sadd(key, value)
    local c = Redis.connect()
    if not c then return false end
    return c:sadd(Redis.key(key), value)
end

function Redis.srem(key, value)
    local c = Redis.connect()
    if not c then return false end
    c:srem(Redis.key(key), value)
    return true
end

function Redis.smembers(key)
    local c = Redis.connect()
    if not c then return {} end
    return c:smembers(Redis.key(key))
end

function Redis.sismember(key, value)
    local c = Redis.connect()
    if not c then return false end
    return c:sismember(Redis.key(key), value) == 1
end

function Redis.exists(key)
    local c = Redis.connect()
    if not c then return false end
    return c:exists(Redis.key(key)) == 1
end

function Redis.expire(key, ttl)
    local c = Redis.connect()
    if not c then return false end
    c:expire(Redis.key(key), ttl)
    return true
end

function Redis.ttl(key)
    local c = Redis.connect()
    if not c then return -1 end
    return tonumber(c:ttl(Redis.key(key))) or -1
end

-- Fallback في حالة عدم وجود Redis — يستخدم جدول في الذاكرة
local fallback_store = {}

Redis.fallback_get = function(key) return fallback_store[key] end
Redis.fallback_set = function(key, val) fallback_store[key] = val end
Redis.fallback_del = function(key) fallback_store[key] = nil end

return Redis
