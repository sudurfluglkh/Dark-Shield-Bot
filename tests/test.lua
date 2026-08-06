-- ============================================================
-- TEST.LUA — اختبارات Dark Shield Bot
-- ============================================================
-- 📅 التاريخ: 2024-11-15
-- 👨‍💻 المبرمج والمطور: @a11y11
-- ============================================================

local tests_passed = 0
local tests_failed = 0

local function assert_eq(actual, expected, name)
    if actual == expected then
        print("  ✅ " .. name)
        tests_passed = tests_passed + 1
    else
        print("  ❌ " .. name .. " (expected: " .. tostring(expected) .. ", got: " .. tostring(actual) .. ")")
        tests_failed = tests_failed + 1
    end
end

local function assert_true(val, name)
    if val then
        print("  ✅ " .. name)
        tests_passed = tests_passed + 1
    else
        print("  ❌ " .. name)
        tests_failed = tests_failed + 1
    end
end

print("🧪 Dark Shield Bot — Tests")
print("================================")

-- ============================================================
-- [1. اختبار Config]
-- ============================================================
print("\n📋 Testing Config...")
local Config = dofile("./src/Config.lua")
assert_true(Config ~= nil, "Config loaded")
assert_eq(Config.version, "7.0", "Version is 7.0")
assert_eq(Config.bot_name, "Dark Shield", "Bot name is Dark Shield")
assert_true(Config.SUDO > 0, "SUDO is set")

-- ============================================================
-- [2. اختبار Utils]
-- ============================================================
print("\n🔧 Testing Utils...")
local Utils = dofile("./src/Utils.lua")
assert_true(Utils ~= nil, "Utils loaded")
assert_eq(Utils.trim("  hello  "), "hello", "Trim works")
assert_eq(#Utils.split("a b c", " "), 3, "Split works")
assert_eq(Utils.format_number(1500), "1.5K", "Format number 1500 -> 1.5K")
assert_eq(Utils.format_number(2000000), "2.0M", "Format number 2M -> 2.0M")
assert_true(Utils.is_empty(nil), "is_empty(nil) = true")
assert_true(not Utils.is_empty("text"), "is_empty('text') = false")

-- ============================================================
-- [3. اختبار Security]
-- ============================================================
print("\n🛡️ Testing Security...")
local Security = dofile("./src/Security.lua")
assert_true(Security ~= nil, "Security loaded")
assert_true(Security.contains_link("https://google.com"), "Detect https link")
assert_true(Security.contains_link("www.google.com"), "Detect www link")
assert_true(Security.contains_link("t.me/alaxla"), "Detect t.me link")
assert_true(not Security.contains_link("hello world"), "No link in plain text")
assert_true(Security.is_whitelisted_link("t.me/alaxla"), "Whitelisted link")

-- ============================================================
-- [4. اختبار Auth]
-- ============================================================
print("\n🔐 Testing Auth...")
local Auth = dofile("./src/Auth.lua")
assert_true(Auth ~= nil, "Auth loaded")
assert_eq(Auth.LEVELS.SUDO, 5, "SUDO level is 5")
assert_eq(Auth.LEVELS.MEMBER, 1, "MEMBER level is 1")
assert_true(Auth.is_sudo(Config.SUDO), "SUDO is_sudo returns true")
assert_true(not Auth.is_sudo(12345), "Non-SUDO is_sudo returns false")

-- ============================================================
-- [5. اختبار Phrases]
-- ============================================================
print("\n📝 Testing Phrases...")
local Phrases = dofile("./src/Phrases.lua")
assert_true(Phrases ~= nil, "Phrases loaded")
-- اختبار load
local jokes = Phrases.load("./data/phrases/jokes.txt")
assert_true(#jokes > 0, "Jokes file has content")
local songs = Phrases.load("./data/phrases/songs.txt")
assert_true(#songs > 0, "Songs file has content")

-- ============================================================
-- [6. اختبار AntiSpam]
-- ============================================================
print("\n🌊 Testing AntiSpam...")
local AntiSpam = dofile("./src/AntiSpam.lua")
assert_true(AntiSpam ~= nil, "AntiSpam loaded")
assert_true(AntiSpam.is_advertisement("تبادل لايك وشبابك"), "Detect advertisement")
assert_true(not AntiSpam.is_advertisement("مرحبا كيف حالك"), "No ad in normal text")

-- ============================================================
-- [7. اختبار Filter]
-- ============================================================
print("\n🔍 Testing Filter...")
local Filter = dofile("./src/Filter.lua")
assert_true(Filter ~= nil, "Filter loaded")

-- ============================================================
-- [8. اختبار Logger]
-- ============================================================
print("\n📋 Testing Logger...")
local Logger = dofile("./src/Logger.lua")
assert_true(Logger ~= nil, "Logger loaded")
assert_eq(Logger.LEVELS.DEBUG, 1, "DEBUG level is 1")
assert_eq(Logger.LEVELS.FATAL, 5, "FATAL level is 5")

-- ============================================================
-- [النتيجة النهائية]
-- ============================================================
print("\n" .. string.rep("=", 40))
print("📊 Results: " .. tests_passed .. " passed, " .. tests_failed .. " failed")
if tests_failed == 0 then
    print("✅ All tests passed!")
else
    print("❌ Some tests failed!")
end
print(string.rep("=", 40))

os.exit(tests_failed > 0 and 1 or 0)
