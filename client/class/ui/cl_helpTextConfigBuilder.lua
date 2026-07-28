
---@type REC_Library.Shared.Validator
local validator = require "@REC_Library.shared.sh_validator"

---@class REC_Library.Client.Class.UI.HelpTextConfigBuilder
---@field args string[]
---@field duration number
---@field hasDrawing boolean
local HelpTextConfigBuilder = {}
HelpTextConfigBuilder.__index = HelpTextConfigBuilder

---instantiation
---@param args string[]
---@return self
function HelpTextConfigBuilder:new(args)
    assert(args ~= nil and validator.isTableOfNumberString(args), "args must be a string[] if provided")
    local instance = setmetatable({}, self)
    instance.args = args
    instance.duration = 5000
    instance.hasDrawing = false
    return instance
end

---Override drawing time
---@param duration number|nil Example: 3000
---@return self
function HelpTextConfigBuilder:setDuration(duration)
    if duration == nil then return self end
    assert(type(duration) == "number", "duration must be number")
    self.duration = duration
    return self
end

---Build
---@return table
function HelpTextConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return HelpTextConfigBuilder
