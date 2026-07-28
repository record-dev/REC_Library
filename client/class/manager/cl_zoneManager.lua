
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@class REC_Library.Client.Class.Manager.ZoneManager
---@field info REC_Library.Client.Class.Manager.ZoneManagerConfigBuilder
local ZoneManager = {}
ZoneManager.__index = ZoneManager

---instantiation
---@param config REC_Library.Client.Class.Manager.ZoneManagerConfigBuilder
---@return self
function ZoneManager:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Zone registration
---@param zoneInstance REC_Library.Client.Class.Zone.Zone Zone identification name
---@return boolean
function ZoneManager:register(zoneInstance)
    local info = self.info

    assert(type(zoneInstance) == "table", "zoneInstance must be a meta table")

    local zoneInfo = zoneInstance.info

    -- Existence confirmation
    if self:doesZoneExist(zoneInfo.name) == true then
        utils:debugPrint("[ZoneManager:unregister] zone already exist:", zoneInfo.name)
        return false
    end

    -- Registration
    info.zones[zoneInfo.name] = zoneInstance

    return true
end

---Zone registration cancellation
---@param zoneName string Zone identification name
---@return boolean
function ZoneManager:unregister(zoneName)
    local info = self.info

    assert(type(zoneName) == "string", "zoneName must be a string")

    -- Existence confirmation
    if self:doesZoneExist(zoneName) == false then
        utils:debugPrint("[ZoneManager:unregister] zone not founded with zoneName:", zoneName)
        return false
    end

    -- Unregister
    info.zones[zoneName] = nil

    return true
end

---Check the existence of zone registration
---@param zoneName string Zone identification name
---@return boolean
function ZoneManager:doesZoneExist(zoneName)
    local info = self.info

    assert(type(zoneName) == "string", "zoneName must be a string")

    return info.zones[zoneName] ~= nil
end

---Get all zones
---@return table<string, REC_Library.Client.Class.Zone.Zone>|
function ZoneManager:getZones()
    local info = self.info

    -- check if empty
    if next(info.zones) == nil then
        utils:debugPrint("[ZoneManager:getZones] zones is nil")
        return {}
    end

    return info.zones or {}
end

---Learn zone information
---@param zoneName string Zone identification name
---@return REC_Library.Client.Class.Zone.Zone|nil
function ZoneManager:getZoneByName(zoneName)
    local info = self.info

    assert(type(zoneName) == "string", "zoneName must be a string")

    -- Existence confirmation
    if self:doesZoneExist(zoneName) == false then
        utils:debugPrint("zone not founded with zoneName:", zoneName)
        return nil
    end

    return info.zones[zoneName]
end

return ZoneManager
