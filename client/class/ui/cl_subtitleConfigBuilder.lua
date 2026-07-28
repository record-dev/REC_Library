
---@class REC_Library.Client.Class.UI.SubtitleConfigBuilder
---@field text string
---@field textEntry string
---@field duration integer
---@field isDrawing boolean
local SubtitleConfigBuilder = {}
SubtitleConfigBuilder.__index = SubtitleConfigBuilder


---instantiation
---@param text string
---@param textEntry string default: STRING
---@param duration integer
---@return self
function SubtitleConfigBuilder:new(text, textEntry, duration)

    assert(type(text) == "string", "text must be a string")
    assert(type(textEntry) == "string", "textEntry must be a string")
    assert(type(duration) == "number", "duration must be a integer|number")

    local instance = setmetatable({}, self)
    instance.text = text
    instance.textEntry = textEntry
    instance.duration = duration
    instance.isDrawing = false
    return instance
end

return SubtitleConfigBuilder
