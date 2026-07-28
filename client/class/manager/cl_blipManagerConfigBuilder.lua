
---@class REC_Library.Client.Class.Manager.BlipManagerConfigBuilder
---@field blips table<string, REC_Library.Client.Class.Blip.Blip>
---@field blipsByGroup table<string, table<string, REC_Library.Client.Class.Blip.Blip>>
---@field keyToGroup table<string, string>
local BlipManagerConfigBuilder = {}
BlipManagerConfigBuilder.__index = BlipManagerConfigBuilder

---instantiation
---@return self
function BlipManagerConfigBuilder:new()
    local instance = setmetatable({}, self)
    instance.blips = {}
    instance.blipsByGroup = {}
    instance.keyToGroup = {}
    return instance
end

return BlipManagerConfigBuilder
