-- ============================================================
-- YOUTUBE.LUA — تحميل وتشغيل من يوتيوب
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local Config = dofile("./src/Config.lua")
local BotAPI = dofile("./src/BotAPI.lua")
local Utils = dofile("./src/Utils.lua")

local YouTube = {}

-- استخراج معرف الفيديو من الرابط
function YouTube.extract_id(url)
    if not url then return nil end
    -- youtu.be/VIDEO_ID
    local id = url:match("youtu%.be/([%w%-_]+)")
    if id then return id end
    -- youtube.com/watch?v=VIDEO_ID
    id = url:match("[?&]v=([%w%-_]+)")
    if id then return id end
    -- youtube.com/embed/VIDEO_ID
    id = url:match("youtube%.com/embed/([%w%-_]+)")
    if id then return id end
    return nil
end

-- البحث في يوتيوب
function YouTube.search(query, max_results)
    if not query then return nil end
    max_results = max_results or 5
    -- استخدام YouTube Data API v3 (يتطلب API key)
    local api_key = os.getenv("YOUTUBE_API_KEY") or ""
    if api_key == "" then
        -- بدون API key — نرجع رابط بحث مباشر
        return "https://www.youtube.com/results?search_query=" .. query:gsub(" ", "+")
    end
    local url = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=" .. max_results .. "&q=" .. query .. "&key=" .. api_key
    local https = require("ssl.https")
    local res = https.request(url)
    return res
end

-- أمر البحث عن فيديو
function YouTube.search_command(msg, args)
    if not args or args == "" then
        BotAPI.sendMessage(msg.chat.id, "استخدم: /youtube اسم الفيديو")
        return
    end
    local link = YouTube.search(args, 1)
    if type(link) == "string" and link:match("^https") then
        BotAPI.sendMessage(msg.chat.id, "🔍 نتائج البحث عن '" .. args .. "':\n\n" .. link)
    else
        BotAPI.sendMessage(msg.chat.id, "🔍 ابحث عن '" .. args .. "':\n\nhttps://www.youtube.com/results?search_query=" .. args:gsub(" ", "+"))
    end
end

-- تنزيل صوت من يوتيوب (يتطلب yt-dlp على السيرفر)
function YouTube.download_audio(msg, args)
    if not args or args == "" then
        BotAPI.sendMessage(msg.chat.id, "استخدم: /song رابط_اليوتيوب")
        return
    end

    local video_id = YouTube.extract_id(args)
    if not video_id then
        -- ربما query وليس رابط
        local link = YouTube.search(args, 1)
        BotAPI.sendMessage(msg.chat.id, "🔍 لا أستطيع تنزيل الصوت مباشرة، لكن ابحث هنا:\n\n" .. (link or "https://www.youtube.com"))
        return
    end

    -- محاولة استخدام yt-dlp
    local cmd = 'yt-dlp -x --audio-format mp3 --audio-quality 0 -o "/tmp/%(id)s.%(ext)s" "https://www.youtube.com/watch?v=' .. video_id .. '" 2>&1'
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()

    local file_path = "/tmp/" .. video_id .. ".mp3"
    local file = io.open(file_path, "rb")
    if file then
        file:close()
        -- إرسال الملف
        BotAPI.request("sendAudio", {chat_id = msg.chat.id, audio = file_path})
        os.remove(file_path)
    else
        BotAPI.sendMessage(msg.chat.id, "❌ لم أستطع تنزيل الصوت. تأكد من تثبيت yt-dlp.")
    end
end

-- تنزيل فيديو من يوتيوب
function YouTube.download_video(msg, args)
    if not args or args == "" then
        BotAPI.sendMessage(msg.chat.id, "استخدم: /video رابط_اليوتيوب")
        return
    end

    local video_id = YouTube.extract_id(args)
    if not video_id then
        BotAPI.sendMessage(msg.chat.id, "❌ رابط غير صحيح.")
        return
    end

    local cmd = 'yt-dlp -f "best[height<=720]" -o "/tmp/%(id)s.%(ext)s" "https://www.youtube.com/watch?v=' .. video_id .. '" 2>&1'
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()

    -- البحث عن الملف الناتج
    local find_cmd = 'ls /tmp/' .. video_id .. '.* 2>/dev/null'
    local h2 = io.popen(find_cmd)
    local file_path = h2:read("*l")
    h2:close()

    if file_path and file_path ~= "" then
        BotAPI.request("sendVideo", {chat_id = msg.chat.id, video = file_path})
        os.remove(file_path)
    else
        BotAPI.sendMessage(msg.chat.id, "❌ لم أستطع تنزيل الفيديو. تأكد من تثبيت yt-dlp.")
    end
end

return YouTube
