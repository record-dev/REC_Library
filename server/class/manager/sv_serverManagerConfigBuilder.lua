
---@class REC_Library.Server.Class.Manager.ServerManagerConfigBuilder
---@field playerManager? REC_Library.Server.Class.Manager.PlayerManager
---@field entityManager? REC_Library.Server.Class.Manager.EntityManager
---@field ownershipManager? REC_Library.Server.Class.Manager.OwnershipManager
---@field zoneManager? REC_Library.Server.Class.Manager.ZoneManager
---@field sequenceManager? REC_Library.Server.Class.Manager.SequenceManager
---@field onInit? fun( self: REC_Library.Server.Class.Manager.ServerManager, ...): boolean
local ServerManagerConfigBuilder = {}
ServerManagerConfigBuilder.__index = ServerManagerConfigBuilder

---instantiation
---@return self
function ServerManagerConfigBuilder:new()
    local instance = setmetatable({}, self)
    return instance
end

---Setter chain method
---@param onInit fun(self: REC_Library.Server.Class.Manager.ServerManager, ...): boolean callback function
---@return self chain method
function ServerManagerConfigBuilder:setOnInit(onInit)
    if onInit == nil then return self end
    assert(type(onInit) == "function", "onInit must be a function")
    self.onInit = onInit
    return self
end

---PlayerManager registration
---@param playerManager REC_Library.Server.Class.Manager.PlayerManager|nil
---@return self
function ServerManagerConfigBuilder:setPlayerManager(playerManager)
    if playerManager == nil then return self end
    assert(type(playerManager) == "table", "playerManagerConfigBuilder must be a table")
    self.playerManager = playerManager
    return self
end

---Storing EntityManager instance
---@param entityManager REC_Library.Server.Class.Manager.EntityManager
---@return self
function ServerManagerConfigBuilder:setEntityManager(entityManager)
    if entityManager == nil then return self end
    self.entityManager = entityManager
    return self
end

---Ownership instance storage
---@param ownershipManager REC_Library.Server.Class.Manager.OwnershipManager|nil
---@return self
function ServerManagerConfigBuilder:setOwnershipManager(ownershipManager)
    if ownershipManager == nil then return self end
    self.ownershipManager = ownershipManager
    return self
end

---ConfigBuilder for ZoneManager instantiation
---@param zoneManager REC_Library.Server.Class.Manager.ZoneManager
function ServerManagerConfigBuilder:setZoneManager(zoneManager)
    if zoneManager == nil then return self end
    self.zoneManager = zoneManager
    return self
end

---Storing sequence instances
---@param sequenceManager REC_Library.Server.Class.Manager.SequenceManager
---@return self
function ServerManagerConfigBuilder:setSequenceManager(sequenceManager)
    if sequenceManager == nil then return self end
    self.sequenceManager = sequenceManager
    return self
end

---Configure custom properties
---@param properties table<string, any>[]|nil
---@return self
function ServerManagerConfigBuilder:setCustomProperties(properties)
    if properties == nil then return self end
    for k, v in pairs(properties) do
        if v ~= nil then self[k] = v end
    end
    return self
end

---Build and return in table format
---@return table
function ServerManagerConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return ServerManagerConfigBuilder
