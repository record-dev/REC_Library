
---[[
---     Text helpers shared by the help text and the subtitle
---]]

---@type REC_Library.Shared.Config
local shCfg = require "@REC_Library.shared.sh_config"

---@class REC_Library.Client.UI.Text
local text = {}

---@type integer
local sequence = 0

---[[
---     issue an id (when the caller did not pass one)
---]]
---@return string
function text:generateId()
    sequence += 1
    return ("rec-%d-%d"):format(GetGameTimer(), sequence)
end

---[[
---     join a string[] into one text (the UI.HelpText class takes one string per line)
---]]
---@param value string|string[]|nil
---@return string|nil
function text:join(value)

    if type(value) == "string" then
        return value
    end

    if type(value) ~= "table" then
        return nil
    end

    local lines = {}

    for _, line in ipairs(value) do
        if type(line) == "string" then
            lines[#lines+1] = line
        end
    end

    if #lines == 0 then
        return nil
    end

    return table.concat(lines, "\n")
end

---[[
---     turn the GTA control tokens into keycaps ("~INPUT_CONTEXT~" -> "[E]")
---     the colour codes (~y~ ~s~ ~n~) are left for the NUI to draw
---]]
---@param value string
---@return string
function text:formatControls(value)

    local formatted = value:gsub("~(INPUT_[%w_]+)~", function (name)
        return ("[%s]"):format(shCfg.ui.helpText.inputKeys[name] or name)
    end)

    return formatted
end

---[[
---     display time, nil or below zero becomes the fallback
---]]
---@param value any
---@param fallback integer
---@return integer
function text:duration(value, fallback)

    local number = tonumber(value)
    if number == nil then
        return fallback
    end

    if number <= 0 then
        return 0
    end

    return math.floor(number)
end

---[[
---     the time a shown text has left, nil when it stays until hidden
---]]
---@param duration integer
---@return integer|nil
function text:expiresAt(duration)

    if duration <= 0 then
        return nil
    end

    return GetGameTimer() + duration
end

---[[
---     a copy of the entry carrying the time it has left (for a NUI reboot)
---]]
---@param entry table
---@param expiresAt integer|nil
---@return table
function text:remaining(entry, expiresAt)

    if expiresAt == nil then
        return entry
    end

    local copy = {}
    for key, value in pairs(entry) do
        copy[key] = value
    end

    copy.duration = math.max(expiresAt - GetGameTimer(), 1)

    return copy
end

return text
