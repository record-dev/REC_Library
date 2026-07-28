
---@class REC_Library.Client.Class.UI.ScaleformConfigBuilder
local ScaleformConfigBuilder = {}
ScaleformConfigBuilder.__index = ScaleformConfigBuilder

---instantiation
---@return self
function ScaleformConfigBuilder:new()
    local instance = setmetatable({}, self)
    return instance
end

---Build
---@return table
function ScaleformConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return ScaleformConfigBuilder
