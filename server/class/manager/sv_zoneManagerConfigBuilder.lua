
---@class REC_Library.Server.Class.Manager.ZoneManagerConfig
---@field zones table<string, REC_Library.Server.Class.Manager.ZoneManagerConfig.Zones>

---@class REC_Library.Server.Class.Manager.ZoneManagerConfigBuilder: REC_Library.Server.Class.Manager.ZoneManagerConfig
local ZoneManagerConfigBuilder = {}
ZoneManagerConfigBuilder.__index = ZoneManagerConfigBuilder

---instantiation
---@return self
function ZoneManagerConfigBuilder:new()
    local instance = setmetatable({}, self)
    instance.zones = {}
    return instance
end

---Generate zone frames with unique zone names
---@param zoneName string Zone name
---@return self
function ZoneManagerConfigBuilder:addZone(zoneName)
    if zoneName == nil then return self end
    assert(self.zones[zoneName] ~= nil, "")
    self.zones[zoneName] = {
        currentPlayers = {},
        history = {},
    }
    return self
end

---Configure custom properties
---@param properties table<string, any>[]|nil
---@return self
function ZoneManagerConfigBuilder:setCustomProperties(properties)
    if properties == nil then return self end
    for k, v in pairs(properties) do
        if v ~= nil then self[k] = v end
    end
    return self
end

---Return with table without method
---@return REC_Library.Server.Class.Manager.ZoneManagerConfig
function ZoneManagerConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

---@class REC_Library.Server.Class.Manager.ZoneManagerConfig.Zones
---@field currentPlayers table<integer, integer>
---@field history table<integer, REC_Library.Server.Class.Manager.ZoneManagerConfig.Zones.History>

---@class REC_Library.Server.Class.Manager.ZoneManagerConfig.Zones.History
---@field src integer Player's server ID
---@field playerFivemName string FiveM name
---@field playerFrameworkName? string Framework name
---@field eventType REC_Library.Shared.Enums.ZoneHistoryEventType Type
---@field timestump integer time


return ZoneManagerConfigBuilder
