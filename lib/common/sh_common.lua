
---[[
---     common (shared)
---     The small helpers ox_lib scripts reach for without thinking.
---]]

---@type string
local resourceName = lib.name

---[[
---     checkDependency
---]]
---@param resource string
---@param minimumVersion string "1.2.3"
---@param printMessage? boolean
---@return boolean ok
---@return string|nil message
function lib.checkDependency(resource, minimumVersion, printMessage)

    local version = GetResourceMetadata(resource, "version", 0)
    if version == nil then
        local message = ("^1%s is not installed, %s needs version %s^0"):format(resource, resourceName, minimumVersion)
        if printMessage == true then
            print(message)
        end
        return false, message
    end

    local current = version:gsub("^v", "")
    local required = minimumVersion:gsub("^v", "")

    local currentParts, requiredParts = {}, {}
    for part in current:gmatch("%d+") do currentParts[#currentParts+1] = tonumber(part) end
    for part in required:gmatch("%d+") do requiredParts[#requiredParts+1] = tonumber(part) end

    for i = 1, math.max(#currentParts, #requiredParts) do

        local a, b = currentParts[i] or 0, requiredParts[i] or 0
        if a > b then
            return true
        end

        if a < b then
            local message = ("^1%s needs %s %s or newer, found %s^0"):format(resourceName, resource, minimumVersion, version)
            if printMessage == true then
                print(message)
            end
            return false, message
        end
    end

    return true
end



---[[
---     print
---]]
---@class REC_Library.Lib.Print
lib.print = {}

---@type table<string, integer>
local printLevels = { error = 1, warn = 2, info = 3, verbose = 4, debug = 5, }

---@type table<string, string>
local printColours = { error = "^1", warn = "^3", info = "^7", verbose = "^4", debug = "^6", }

---@type integer
local printLevel = printLevels[GetConvar("rec:printlevel", "info")] or 3

for level, weight in pairs(printLevels) do
    lib.print[level] = function (...)

        if weight > printLevel then
            return
        end

        local parts = { ... }
        for i = 1, select("#", ...) do
            local value = parts[i]
            parts[i] = type(value) == "table" and json.encode(value) or tostring(value)
        end

        print(("%s[%s] [%s] %s^0"):format(printColours[level], level:upper(), resourceName, table.concat(parts, " ")))
    end
end



---[[
---     waitFor
---     Wait until cb returns something other than nil, error after timeout ms.
---]]
---@generic T
---@param cb fun(): T?
---@param errMessage? string
---@param timeout? number ms, default 1000. false waits forever
---@return T
function lib.waitFor(cb, errMessage, timeout)

    local value = cb()
    if value ~= nil then
        return value
    end

    if timeout == nil then
        timeout = 1000
    end

    local start = GetGameTimer()

    while value == nil do

        if timeout ~= false and GetGameTimer() - start > timeout then
            error(("%s (waited %sms)"):format(errMessage or "failed to resolve callback", timeout), 2)
        end

        Wait(0)
        value = cb()
    end

    return value
end



---[[
---     timer
---]]
---@class REC_Library.Lib.Timer
---@field private startTime integer
---@field private duration integer
---@field private paused boolean
---@field private pausedAt integer
---@field private ended boolean
---@field private onEnd? fun(self: REC_Library.Lib.Timer)
local Timer = {}
Timer.__index = Timer

---@param format? "ms" | "s" | "m" | "h"
---@return number
function Timer:getTimeLeft(format)

    local elapsed = (self.paused == true and self.pausedAt or GetGameTimer()) - self.startTime
    local left = math.max(0, self.duration - elapsed)

    if format == "s" then return left / 1000 end
    if format == "m" then return left / 60000 end
    if format == "h" then return left / 3600000 end

    return left
end

function Timer:pause()

    if self.paused == true or self.ended == true then
        return
    end

    self.paused = true
    self.pausedAt = GetGameTimer()
end

function Timer:play()

    if self.paused == false or self.ended == true then
        return
    end

    self.startTime += GetGameTimer() - self.pausedAt
    self.paused = false
end

---@return boolean
function Timer:isPaused()
    return self.paused
end

---@param triggerOnEnd? boolean
function Timer:forceEnd(triggerOnEnd)

    if self.ended == true then
        return
    end

    self.ended = true

    if triggerOnEnd ~= false and self.onEnd ~= nil then
        self:onEnd()
    end
end

---@param time integer ms
---@param onEnd? fun(self: REC_Library.Lib.Timer)
---@param async? boolean true returns at once, otherwise blocks until the timer ends
---@return REC_Library.Lib.Timer
function lib.timer(time, onEnd, async)

    assert(type(time) == "number", "time must be a number")

    local timer = setmetatable({
        startTime = GetGameTimer(),
        duration = time,
        paused = false,
        pausedAt = 0,
        ended = false,
        onEnd = onEnd,
    }, Timer)

    local function run()
        while timer.ended == false do
            if timer.paused == false and timer:getTimeLeft() <= 0 then
                timer:forceEnd(true)
                break
            end
            Wait(0)
        end
    end

    if async == true then
        CreateThread(run)
    else
        run()
    end

    return timer
end



---[[
---     string
---]]
---@class REC_Library.Lib.String
lib.string = {}

---@type table<string, string>
local randomSets = {
    ["1"] = "0123456789",
    ["A"] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    ["a"] = "abcdefghijklmnopqrstuvwxyz",
    ["."] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
}

---[[
---     "1" digit, "A" upper, "a" lower, "." any, "^x" the literal x
---]]
---@param pattern string
---@param length? integer repeat the pattern until this length
---@return string
function lib.string.random(pattern, length)

    local out = {}
    local i = 1
    local patternLength = #pattern

    while true do

        local char = pattern:sub(i, i)
        if char == "^" then
            i += 1
            out[#out+1] = pattern:sub(i, i)
        else
            local set = randomSets[char]
            if set == nil then
                out[#out+1] = char
            else
                local index = math.random(1, #set)
                out[#out+1] = set:sub(index, index)
            end
        end

        i += 1

        if length == nil then
            if i > patternLength then break end
        else
            if #out >= length then break end
            if i > patternLength then i = 1 end
        end
    end

    return table.concat(out)
end



---[[
---     math
---]]
---@class REC_Library.Lib.Math
lib.math = {}

---@param value number
---@param places? integer
---@return number
function lib.math.round(value, places)

    if places == nil or places == 0 then
        return math.floor(value + 0.5)
    end

    local factor = 10 ^ places
    return math.floor(value * factor + 0.5) / factor
end

---@param value number
---@param min number
---@param max number
---@return number
function lib.math.clamp(value, min, max)
    return math.min(math.max(value, min), max)
end

---@param hex string "#00ff88" or "00ff88"
---@return integer r
---@return integer g
---@return integer b
function lib.math.hexToRgb(hex)

    hex = hex:gsub("^#", "")

    if #hex == 3 then
        hex = hex:gsub(".", "%0%0")
    end

    return tonumber(hex:sub(1, 2), 16) or 0, tonumber(hex:sub(3, 4), 16) or 0, tonumber(hex:sub(5, 6), 16) or 0
end

---@param input string | table | vector2 | vector3 | vector4
---@return number ...
function lib.math.toscalars(input)

    if type(input) == "string" then
        local numbers = {}
        for value in input:gmatch("[%-%d%.]+") do
            numbers[#numbers+1] = tonumber(value)
        end
        return table.unpack(numbers)
    end

    if type(input) == "table" then
        return input.x or input[1], input.y or input[2], input.z or input[3], input.w or input[4]
    end

    return input.x, input.y, input.z, input.w
end

---@param input string | table | vector2 | vector3 | vector4
---@return vector2 | vector3 | vector4 | number
function lib.math.tovector(input)

    local x, y, z, w = lib.math.toscalars(input)

    if w ~= nil then return vector4(x, y, z, w) end
    if z ~= nil then return vector3(x, y, z) end
    if y ~= nil then return vector2(x, y) end

    return x
end

---@param input string "rgb(0, 255, 136)" or "rgba(0, 255, 136, 0.5)"
---@return integer r
---@return integer g
---@return integer b
---@return integer a 0-255
function lib.math.torgba(input)

    local r, g, b, a = lib.math.toscalars(input)
    a = a == nil and 255 or (a <= 1 and math.floor(a * 255 + 0.5) or math.floor(a))

    return math.floor(r or 0), math.floor(g or 0), math.floor(b or 0), a
end

---@param coords vector3
---@return vector3
function lib.math.normal(coords)

    local length = #coords
    if length == 0 then
        return vector3(0.0, 0.0, 0.0)
    end

    return coords / length
end



---[[
---     getRelativeCoords
---     A point offset from coords, turned by heading (degrees)
---]]
---@param coords vector3 | vector4
---@param heading number | vector3 heading, or the offset when coords carries the heading
---@param offset? vector3
---@return vector3 | vector4
function lib.getRelativeCoords(coords, heading, offset)

    if offset == nil then
        offset = heading --[[@as vector3]]
        heading = coords.w
    end

    local rad = math.rad(heading)
    local cos, sin = math.cos(rad), math.sin(rad)

    local x = coords.x + offset.x * cos - offset.y * sin
    local y = coords.y + offset.x * sin + offset.y * cos
    local z = coords.z + offset.z

    if type(coords) == "vector4" then
        return vector4(x, y, z, coords.w)
    end

    return vector3(x, y, z)
end



---[[
---     load / loadJson
---     Read a file of this resource (or '@Resource.path') without caching it.
---]]
---@param modName string
---@return string resource
---@return string path
local function resolvePath(modName)

    local resource, path = modName:match("^@([^%.]+)%.(.+)$")
    if resource == nil then
        resource, path = resourceName, modName
    end

    return resource, (path:gsub("%.", "/"))
end

---@param modName string
---@param env? table
---@return any
function lib.load(modName, env)

    local resource, path = resolvePath(modName)
    local source = LoadResourceFile(resource, path .. ".lua")
    if source == nil then
        error(("file '%s' not found (%s/%s.lua)"):format(modName, resource, path), 2)
    end

    local chunk, err = load(source, ("@@%s/%s.lua"):format(resource, path), "t", env or _ENV)
    if chunk == nil then
        error(err, 2)
    end

    return chunk()
end

---@param modName string
---@return any
function lib.loadJson(modName)

    local resource, path = resolvePath(modName)
    local source = LoadResourceFile(resource, path .. ".json")
    if source == nil then
        error(("file '%s' not found (%s/%s.json)"):format(modName, resource, path), 2)
    end

    return json.decode(source)
end



---[[
---     locale
---     lib.locale() reads locales/<language>.json of this resource (en as fallback),
---     locale(key, ...) formats one string. The language comes from REC_Library's config.
---]]
---@type table<string, string>
local localeStrings = {}

---@type boolean
local localeLoaded = false

---@param name string
---@return table<string, string>|nil
local function readLocale(name)

    local raw = LoadResourceFile(resourceName, ("locales/%s.json"):format(name))
    if raw == nil then
        return nil
    end

    local decoded = json.decode(raw)
    if type(decoded) ~= "table" then
        return nil
    end

    return decoded
end

---@param key? string load this language instead of the configured one
function lib.locale(key)

    local language = key
    if language == nil then
        local shCfg = require "@REC_Library.shared.sh_config"
        language = shCfg.language
    end

    localeStrings = readLocale(language) or readLocale("en") or {}
    localeLoaded = true
end

---@param key string
---@param ... any
---@return string
function lib.getLocale(key, ...)

    if localeLoaded == false then
        lib.locale()
    end

    local text = localeStrings[key]
    if text == nil then
        return key
    end

    if select("#", ...) > 0 then
        return text:format(...)
    end

    return text
end

---@param key string
---@param ... any
---@return string
function locale(key, ...)
    return lib.getLocale(key, ...)
end
