
---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

---[[
--- Class with server-side central management responsibilities
---]]

---@class REC_Library.Server.Class.Manager.ServerManager
---@field info REC_Library.Server.Class.Manager.ServerManagerConfigBuilder
local ServerManager = {}
ServerManager.__index = ServerManager

---instantiation
---@param config REC_Library.Server.Class.Manager.ServerManagerConfigBuilder
---@return self
function ServerManager:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Haste initialization
---@param ... any
---@return boolean Is it possible to start?
function ServerManager:init(...)
    local info = self.info

    -- PlayerManger initialization
    if info.playerManager ~= nil then
        info.playerManager:init()
    end

    if info.onInit == nil then
        utils:debugPrint("^1onInit is not set.^0")
    end

    return info.onInit(self, ...)
end

---start server manager
---@return boolean
function ServerManager:startManagePlayers()
    local info = self.info

    -- Manager existence check
    if info.playerManager == nil then
        utils:debugPrint("[ServerManager] PlayerManager is not set.")
        return false
    end

    if info.playerManager:start() == false then
        return false
    end

    return true
end

---stop in server manager
---@return boolean
function ServerManager:stopManagePlayers()
    local info = self.info

    -- Manager existence check
    if info.playerManager == nil then
        utils:debugPrint("[ServerManager] PlayerManager is not set.")
        return false
    end

    if info.playerManager:stop() == false then
        return false
    end

    return true
end

---Player registration
---@param src string Player source ID
---@return boolean
function ServerManager:registerPlayer(src)
    local info = self.info

    assert(src ~= nil and type(src) == "string", "src must be a string")

    -- Manager existence check
    if info.playerManager == nil then
        utils:debugPrint("[ServerManager] PlayerManager is not set.")
        return false
    end

    -- Registration
    if info.playerManager:register(src) == false then
        utils:debugPrint("ServerManager:registerPlayer: Failed to register player with src: " .. tostring(src))
        return false
    end

    return true
end

---Cancel player registration
---@param src string Player source ID
---@return boolean
function ServerManager:unregisterPlayer(src)
    local info = self.info

    assert(src ~= nil and type(src) == "string", "src must be a string")

    -- Manager existence check
    if info.playerManager == nil then
        utils:debugPrint("[ServerManager] PlayerManager is not set.")
        return false
    end

    -- Unregister
    if info.playerManager:unregister(src) == false then
        utils:debugPrint("ServerManager:unregisterPlayer: Failed to unregister player with src: " .. tostring(src))
        return false
    end

    return true
end

---Get Player instance from player ID
---@param src string
---@return REC_Library.Server.Class.Player.Player|nil
function ServerManager:getPlayerFromSrc(src)
    local info = self.info

    -- Manager existence check
    if info.playerManager == nil then
        utils:debugPrint("[ServerManager] PlayerManager is not set.")
        return nil
    end

    return info.playerManager:getPlayerFromSrc(src)
end

---Check player presence
---@param src integer
---@return boolean
function ServerManager:doesPlayerExist(src)
    local info = self.info

    -- Manager existence check
    if info.playerManager == nil then
        utils:debugPrint("[ServerManager] PlayerManager is not set.")
        return false
    end

    return info.playerManager:doesPlayerExist(tostring(src))
end

---Get player
---@param coords vector3
---@param radius number
---@param sort? boolean
---@return table<string, REC_Library.Server.Class.Manager.PlayerManager.getPlayersInRadius>|nil
function ServerManager:getPlayersInRadius(coords, radius, sort)
    local info = self.info
    sort = sort or nil

    -- Manager existence check
    if info.playerManager == nil then
        utils:debugPrint("[ServerManager] PlayerManager is not set.")
        return nil
    end

    return info.playerManager:getPlayersInRadius(coords, radius, sort)
end

---Zone registration
---@param zoneName string Zone identification name
---@return boolean
function ServerManager:registerZone(zoneName)
    local info = self.info

    -- Check existence of ZoneManager
    if info.zoneManager == nil then
        utils:debugPrint("")
        return false
    end

    -- Registration
    if info.zoneManager:register(zoneName) == false then
        utils:debugPrint("")
        return false
    end

    return true
end

---Deregister zone
---@param zoneName string Zone identification name
---@return boolean
function ServerManager:unregisterZone(zoneName)
    local info = self.info

    -- Check existence of ZoneManager
    if info.zoneManager == nil then
        utils:debugPrint("zoneManaer is nil")
        return false
    end

    -- Unregister
    if info.zoneManager:unregister(zoneName) == false then
        utils:debugPrint("failed to unregister zone with zoneName:", zoneName)
        return false
    end

    return true
end

---Get all zones
---@return table<string, REC_Library.Server.Class.Manager.ZoneManagerConfig.Zones>|nil
function ServerManager:getZones()
    local info = self.info

    -- Check existence of ZoneManager
    if info.zoneManager == nil then
        utils:debugPrint("zoneManaer is nil")
        return nil
    end

    return info.zoneManager:getZones()
end

---Checking the existence of a zone with a specific distinguished name
---@param zoneName string Zone identification name
---@return boolean
function ServerManager:doesZoneExist(zoneName)
    local info = self.info

    -- Check existence of ZoneManager
    if info.zoneManager == nil then
        utils:debugPrint("zoneManaer is nil")
        return false
    end

    return info.zoneManager:doesZoneExist(zoneName)
end

---Entity registration
---@param uid string Unique identifier
---@param syncType REC_Library.Shared.Enums.EntitySyncType Sync type
---@param entityInstance? REC_Library.Server.Class.Object.Object|REC_Library.Server.Class.Ped.Ped|REC_Library.Server.Class.Vehicle.Vehicle Entity instance
---@param netId? integer netId
---@param creatorId? integer creator(NetId)
---@param zoneName? string Specify the zone to which it belongs
---@param callbacks? REC_Library.Server.Class.Manager.OwnershipManagerConfigBuilder.Entities.Callbacks Callback specification
---@return boolean
function ServerManager:registerEntity(uid, syncType, entityInstance, netId, creatorId, zoneName, callbacks)
    local info = self.info

    -- Manager existence check
    if info.entityManager == nil then
        utils:debugPrint("[ServerManager] EntityManager is not set.")
        return false
    end

    assert(uid ~= nil and type(uid) == "string", "uid must be a string")
    assert(syncType ~= nil and type(syncType) == "string", "syncType must be a string" )

    -- Verify as required item for server synchronization
    if syncType == "server" then
        assert(netId ~= nil and type(netId) == "number", "netId must be a number")
        assert(entityInstance ~= nil and type(entityInstance) == "table", "entityInstance must be a table")
        assert(creatorId ~= nil and type(creatorId) == "number", "creatorId must be a number")

        -- whether there is an ownership instance
        if info.ownershipManager == nil then
            utils:debugPrint("ServerManager:registerEntity: OwnershipManager is not set, cannot register netId: " .. tostring(netId))
            return false
        end

        -- Register if not registered
        if info.ownershipManager:getDataByNetId(netId) ~= nil then
            utils:debugPrint("ServerManager:registerEntity: NetId already registered: " .. tostring(netId))
            return false
        end

        -- Register
        if info.ownershipManager:register(netId, callbacks) == false then
            utils:debugPrint("ServerManager:registerEntity: Failed to register netId: " .. tostring(netId))
            return false
        end
    end

    -- Registration application
    if info.entityManager:register(
        uid,
        {
            syncType = syncType,
            entityInstance = entityInstance or nil,
            netId = netId or nil,
            creatorId = creatorId or nil,
            zoneName = zoneName or nil,
        }
    ) == false then
        utils:debugPrint("ServerManager:registerEntity: Failed to register entity with uid: " .. uid)
        return false
    end

    return true
end

---Unregister Entity
---@param uid string Unique distinguished name
---@return boolean
function ServerManager:unregisterEntity(uid)
    local info = self.info

    -- Manager existence check
    if info.entityManager == nil then
        utils:debugPrint("[ServerManager] EntityManager is not set.")
        return false
    end

    assert(uid ~= nil and type(uid) == "string", "uid must be a string")

    local entityData = info.entityManager:getDataByUniqueId(uid)

    -- Skip if empty
    if entityData == nil then
        utils:debugPrint("ServerManager:unregisterEntity: Entity not found with uid: " .. uid)
        return false
    end

    -- For server side
    if entityData.syncType == "server" then

        -- Get netId
        local entityNetId = entityData.netId

        -- If managed by OwnershipManager, remove from management
        if entityNetId ~= nil and info.ownershipManager ~= nil and info.ownershipManager:getDataByNetId(entityNetId) ~= nil then

            -- Release management by owner
            if info.ownershipManager:unregister(entityNetId) == false then
                utils:debugPrint("EntityManager:destroy: Failed to unregister netId: " .. tostring(entityNetId))
                return false
            end
        end

        -- destroy
        if entityData.entityInstance:destroy() == false then
            utils:debugPrint("EntityManager:destroy: Failed to destroy entity with uid: " .. uid)
            return false
        end

    elseif entityData.syncType == "client" then

        -- If the entity to be unregistered has Zone information
        if entityData.zoneName ~= nil and info.zoneManager ~= nil then

            -- Get list of participating players
            local players = info.zoneManager:getPlayersInZone(entityData.zoneName)

            -- Trigger sync client events for participating players in order
            if players ~= nil and next(players) ~= nil then
                -- for src, _ in pairs(players) do
                -- -- Specify the event name to issue a deletion command to the Client in ConfigBuilder
                --     -- TriggerClientEvent("", src, uid)
                -- end
            end
        end
    end

    -- Unregister
    if info.entityManager:unregister(uid) == false then
        utils:debugPrint("ServerManager:unregisterEntity: Failed to unregister entity with uid: " .. uid)
        return false
    end

    return true
end

---Drop an entity registration whose entity is already gone.
---Ownership and uid are released, nothing is destroyed.
---@param uid string Unique distinguished name
---@return boolean
function ServerManager:forgetEntity(uid)
    local info = self.info

    -- Manager existence check
    if info.entityManager == nil then
        utils:debugPrint("[ServerManager] EntityManager is not set.")
        return false
    end

    assert(uid ~= nil and type(uid) == "string", "uid must be a string")

    local entityData = info.entityManager:getDataByUniqueId(uid)

    -- Skip if empty
    if entityData == nil then
        utils:debugPrint("ServerManager:forgetEntity: Entity not found with uid: " .. uid)
        return false
    end

    -- Release management by owner
    local entityNetId = entityData.netId
    if entityData.syncType == "server"
        and entityNetId ~= nil
        and info.ownershipManager ~= nil
        and info.ownershipManager:getDataByNetId(entityNetId) ~= nil
    then
        if info.ownershipManager:unregister(entityNetId) == false then
            utils:debugPrint("ServerManager:forgetEntity: Failed to unregister netId: " .. tostring(entityNetId))
        end
    end

    return info.entityManager:forget(uid)
end

---@param needDestroy? boolean
---@return boolean
function ServerManager:unregisterAllEntity(needDestroy)
    local info = self.info
    needDestroy = needDestroy or false

    -- Manager existence check
    if info.entityManager == nil then
        utils:debugPrint("[ServerManager] EntityManager is not set.")
        return false
    end

    return info.entityManager:unregisterAll(needDestroy)
end

---Get a list of entities registered in the zone
---@param zoneName string
---@return table<string, REC_Library.Server.Class.Manager.EntityManager.getEntitiesByZoneName.ResultEntities>|nil
function ServerManager:getEntitiesByZone(zoneName)
    local info = self.info

    -- Manager existence check
    if info.entityManager == nil then
        utils:debugPrint("[ServerManager] EntityManager is not set.")
        return nil
    end

    assert(zoneName ~= nil and type(zoneName) == "string", "zoneName must be a string")

    return info.entityManager:getEntitiesByZoneName(zoneName)
end

---Get Entity
---@param uid string Unique distinguished name
---@return REC_Library.Server.Class.Manager.EntityManagerConfigBuilder.EntitiesByUniqueId|nil
function ServerManager:getEntityByUniqueId(uid)
    local info = self.info

    -- Manager existence check
    if info.entityManager == nil then
        utils:debugPrint("[ServerManager] EntityManager is not set.")
        return nil
    end

    assert(uid ~= nil and type(uid) == "string", "uid must be a string")

    return info.entityManager:getDataByUniqueId(uid)
end

---Get the current owner of Entity
---@param uid string Unique distinguished name
---@return integer|nil
function ServerManager:getEntityOwnerByUniqueId(uid)
    local info = self.info

    local entityDataOnEM = info.entityManager:getDataByUniqueId(uid)

    -- Check if it is registered in EntityManager
    if entityDataOnEM == nil then
        utils:debugPrint("ServerManager:getEntityOwnerByUniqueId: Entity not found with uid: " .. uid)
        return nil
    end

    -- Check if the desired value is empty
    if entityDataOnEM.netId == nil then
        utils:debugPrint("ServerManager:getEntityOwnerByUniqueId: Entity netId is nil with uid: " .. uid)
        return nil
    end

    local entityDataOnOM = info.ownershipManager:getDataByNetId(entityDataOnEM.netId)

    -- Check if it is registered in OwnershipManager
    if entityDataOnOM == nil then
        utils:debugPrint("ServerManager:getEntityOwnerByUniqueId: Ownership data not found with netId: " .. tostring(entityDataOnEM.netId))
        return nil
    end

    return entityDataOnOM.owner
end

---Execute next sequence function
---@return boolean
function ServerManager:executeNextSequnce()
    local info = self.info

    -- Cancel if empty
    if info.sequenceManager == nil then
        utils:debugPrint("[ServerManager] SequenceManager is not set.")
        return false
    end

    -- Validate registration
    return info.sequenceManager:executeNext()
end

return ServerManager
