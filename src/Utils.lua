-- ============================================================
-- UTILS.LUA — دوال مساعدة
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local Utils = {}

-- تقسيم نص
function Utils.split(text, sep)
    sep = sep or " "
    local parts = {}
    for part in text:gmatch("[^" .. sep .. "]+") do
        table.insert(parts, part)
    end
    return parts
end

-- تقليم النص
function Utils.trim(text)
    if not text then return "" end
    return text:gsub("^%s+", ""):gsub("%s+$", "")
end

-- تحويل لأحرف صغيرة
function Utils.lower(text)
    if not text then return "" end
    return text:lower()
end

-- تحديد جزء من النص
function Utils.substring(text, start_pos, end_pos)
    if not text then return "" end
    return text:sub(start_pos, end_pos)
end

-- استبدال نص
function Utils.replace(text, old, new)
    if not text then return "" end
    return text:gsub(old, new)
end

-- تحويل الرقم لتنسيق مقروء
function Utils.format_number(n)
    n = tonumber(n) or 0
    if n >= 1000000 then
        return string.format("%.1fM", n / 1000000)
    elseif n >= 1000 then
        return string.format("%.1fK", n / 1000)
    else
        return tostring(n)
    end
end

-- تنسيق الوقت
function Utils.format_time(seconds)
    seconds = tonumber(seconds) or 0
    if seconds < 60 then
        return seconds .. " ثانية"
    elseif seconds < 3600 then
        return math.floor(seconds / 60) .. " دقيقة"
    elseif seconds < 86400 then
        return math.floor(seconds / 3600) .. " ساعة"
    else
        return math.floor(seconds / 86400) .. " يوم"
    end
end

-- الحصول على الوقت الحالي منسق
function Utils.now()
    return os.date("%Y-%m-%d %H:%M:%S")
end

-- الحصول على التاريخ
function Utils.date()
    return os.date("%Y-%m-%d")
end

-- الحصول على الوقت
function Utils.time()
    return os.date("%H:%M:%S")
end

-- تحقق إن كان نص فارغ
function Utils.is_empty(text)
    return text == nil or text == ""
end

-- تكرار نص
function Utils.replicate(text, n)
    return string.rep(text or "", n or 1)
end

-- الحصول على اسم مستخدم كامل
function Utils.full_name(user)
    if not user then return "غير معروف" end
    local name = user.first_name or ""
    if user.last_name then
        name = name .. " " .. user.last_name
    end
    if name == "" then
        name = user.username or "غير معروف"
    end
    return name
end

-- ذكر مستخدم
function Utils.mention(user)
    if not user then return "" end
    if user.username then
        return "@" .. user.username
    else
        local name = user.first_name or "المستخدم"
        return "[" .. name .. "](tg://user?id=" .. tostring(user.id) .. ")"
    end
end

-- تحويل جدول لـ JSON string (بسيط)
function Utils.table_to_string(t)
    if type(t) ~= "table" then return tostring(t) end
    local parts = {}
    for k, v in pairs(t) do
        table.insert(parts, tostring(k) .. "=" .. tostring(v))
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

-- قيمة عشوائية من جدول
function Utils.random_choice(arr)
    if not arr or #arr == 0 then return nil end
    math.randomseed(os.time() + math.random(1, 9999))
    return arr[math.random(#arr)]
end

-- تأخير
function Utils.sleep(seconds)
    os.execute("sleep " .. tonumber(seconds or 1))
end

-- تشفير بسيط (Base64-like XOR)
function Utils.simple_hash(text)
    if not text then return "" end
    local hash = 0
    for i = 1, #text do
        hash = ((hash * 31) + string.byte(text, i)) % 2147483647
    end
    return tostring(hash)
end

-- التحقق من صحة المعرف
function Utils.is_valid_id(id)
    id = tonumber(id)
    return id and id > 0
end

-- استخراج معرف من نص
function Utils.extract_id(text)
    if not text then return nil end
    return tonumber(text:match("%d+"))
end

-- استخراج معرف المستخدم من @username
function Utils.extract_username(text)
    if not text then return nil end
    return text:match("@([a-zA-Z0-9_]+)")
end

return Utils
