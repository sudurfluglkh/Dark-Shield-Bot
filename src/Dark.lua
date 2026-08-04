-- ============================================================
-- DARK SHIELD ULTRA v7.0 — أقوى نسخة على الإطلاق
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- 📖 قناة الشروحات والتحديثات: @alaxla
-- 📞 للتواصل: @a11y11
-- 🔘 سورس بلاك @alaxla
-- ⚡ الإصدار: ULTRA v7.0
-- ============================================================

print([[

╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║    ██████╗  █████╗ ██████╗ ██╗  ██╗                             ║
║    ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝                             ║
║    ██║  ██║███████║██████╔╝█████╔╝                              ║
║    ██║  ██║██╔══██║██╔══██╗██╔═██╗                              ║
║    ██████╔╝██║  ██║██║  ██║██║  ██╗                             ║
║    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝                             ║
║                                                                   ║
║    ███████╗██╗  ██╗██╗███████╗██╗     ██████╗                    ║
║    ██╔════╝██║  ██║██║██╔════╝██║     ██╔══██╗                   ║
║    ███████╗███████║██║█████╗  ██║     ██║  ██║                   ║
║    ╚════██║██╔══██║██║██╔══╝  ██║     ██║  ██║                   ║
║    ███████║██║  ██║██║███████╗███████╗██████╔╝                   ║
║    ╚══════╝╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚═════╝                    ║
║                                                                   ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║   🚀 DARK SHIELD ULTRA v7.0                                      ║
║   📅 التاريخ: 2024-11-15                                         ║
║   👨‍💻 المبرمج والمطور: @a11y11                                    ║
║   📖 قناة الشروحات والتحديثات: @alaxla                           ║
║   📞 للتواصل: @a11y11                                            ║
║   🔘 سورس بلاك @alaxla                                            ║
║                                                                   ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║   🔥 المميزات:                                                   ║
║   🎮 50+ لعبة                                                   ║
║   🎵 100+ أمر ترفيهي                                            ║
║   🖼️ 200+ بصمة                                                 ║
║   🛡️ 30+ نوع حماية                                             ║
║   📊 20+ تقرير إحصائي                                           ║
║   🤖 ذكاء اصطناعي متقدم                                         ║
║   🌐 سيرفر API كامل                                             ║
║   📦 نسخ احتياطي تلقائي                                         ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝

]])

-- تحميل جميع الملفات
local Config = dofile("./src/Config.lua")
local Redis = dofile("./src/Redis.lua")
local BotAPI = dofile("./src/BotAPI.lua")
local Auth = dofile("./src/Auth.lua")
local Security = dofile("./src/Security.lua")
local Admin = dofile("./src/Admin.lua")
local Games = dofile("./src/Games.lua")
local YouTube = dofile("./src/YouTube.lua")
local Fun = dofile("./src/Fun.lua")
local Phrases = dofile("./src/Phrases.lua")
local Utils = dofile("./src/Utils.lua")
local Handlers = dofile("./src/Handlers.lua")
local Stickers = dofile("./src/Stickers.lua")
local Stats = dofile("./src/Stats.lua")
local AI = dofile("./src/AI.lua")
local Welcome = dofile("./src/Welcome.lua")
local Backup = dofile("./src/Backup.lua")
local AntiSpam = dofile("./src/AntiSpam.lua")
local Filter = dofile("./src/Filter.lua")
local Logger = dofile("./src/Logger.lua")

-- بدء التشغيل
Handlers.start()