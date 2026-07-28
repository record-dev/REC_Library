
---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

---[[
--- A class that is responsible for managing the entry and exit of players who enter the zone.
---]]

---@class REC_Library.Server.Class.Manager.ZoneManager
---@field info REC_Library.Server.Class.Manager.ZoneManagerConfigBuilder
local ZoneManager = {}
ZoneManager.__index = ZoneManager

---instantiation
---@param config REC_Library.Server.Class.Manager.ZoneManagerConfigBuilder
---@return self
function ZoneManager:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Register new zone
---@param zoneName string Zone identification name
---@return boolean
function ZoneManager:register(zoneName)
    local info = self.info

    -- Existence confirmation
    if self:doesZoneExist(zoneName) == true then
        utils:debugPrint(zoneName, "is exist.")
        return false
    end

    -- Registration
    info.zones[zoneName] = {
        currentPlayers = {},
        history = {},
    }

    return true
end

---Unregister Thorn1
---@param zoneName string
---@return boolean
function ZoneManager:unregister(zoneName)
    local info = self.info

    -- Existence confirmation
    if self:doesZoneExist(zoneName) == false then
        utils:debugPrint(zoneName, "is not exist.")
        return false
    end

    -- Unregister
    info.zones[zoneName] = nil

    return true
end

---[[
--- Get the players in the zone with the specified zone name
--- key, value both player's src
---]]
---@param zoneName string Zone identification name
---@return table<integer, integer>|nil 
function ZoneManager:getPlayersInZone(zoneName)
    local info = self.info

    -- Existence confirmation
    if self:doesZoneExist(zoneName) == false then
        utils:debugPrint("ZoneManager:getPlayersInZone: Zone not found: " .. zoneName)
        return nil
    end

    return info.zones[zoneName].currentPlayers
end

---When a player enters the zone
---@param zoneName string
---@param src integer
---@return boolean
function ZoneManager:onEnter(zoneName, src)
    local info = self.info

    -- Existence confirmation
    if self:doesZoneExist(zoneName) == false then
        utils:debugPrint("ZoneManager:onEnter: Zone not found: " .. zoneName)
        return false
    end

    -- Update
    info.zones[zoneName].currentPlayers[src] = src

    -- keep records
    info.zones[zoneName].history[#info.zones[zoneName].history+1] = {
        src = src,
        playerFivemName = GetPlayerName(src),
        -- playerFrameworkName = "",
        eventType = "enter",
        timestump = os.time(),
    }

    return true
end

---When a player leaves the zone
---@param zoneName string
---@param src integer
---@return boolean
function ZoneManager:onExit(zoneName, src)
    local info = self.info

    -- Existence confirmation
    if self:doesZoneExist(zoneName) == false then
        utils:debugPrint("ZoneManager:onExit: Zone not found: " .. zoneName)
        return false
    end

    -- Update
    info.zones[zoneName].currentPlayers[src] = nil

    -- keep records
    info.zones[zoneName].history[#info.zones[zoneName].history+1] = {
        src = src,
        playerFivemName = GetPlayerName(src),
        -- playerFrameworkName = "",
        eventType = "exit",
        timestump = os.time(),
    }

    return true
end

---Get all zones
---@return table<string, REC_Library.Server.Class.Manager.ZoneManagerConfig.Zones>|nil
function ZoneManager:getZones()
    local info = self.info
    return (info.zones ~= nil and next(info.zones) ~= nil) and info.zones or nil
end

---Checking the existence of a zone with a specific distinguished name
---@param zoneName string Zone identification name
---@return boolean
function ZoneManager:doesZoneExist(zoneName)
    local info = self.info
    return info.zones[zoneName] ~= nil
end

return ZoneManager
