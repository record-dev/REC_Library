
---@class REC_Library.Client.Class.Manager.ZoneManagerConfigBuilder
---@field zones table<string, REC_Library.Client.Class.Zone.Zone>
local ZoneManagerConfigBuilder = {}
ZoneManagerConfigBuilder.__index = ZoneManagerConfigBuilder

---instantiation
---@return self
function ZoneManagerConfigBuilder:new()
    local instance = setmetatable({}, self)
    instance.zones = {}
    return instance
end

return ZoneManagerConfigBuilder
