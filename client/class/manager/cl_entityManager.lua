
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---[[
--- Responsible only for client-side Entity unregistration
---]]


---@class REC_Library.Client.Class.Manager.EntityManager
---@field info REC_Library.Client.Class.Manager.EntityManagerConfigBuilder
local EntityManager = {}
EntityManager.__index = EntityManager

---instantiation
---@param config REC_Library.Client.Class.Manager.EntityManagerConfigBuilder
---@return self
function EntityManager:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Registration
---@param uid string Unique distinguished name
---@param entityInstance REC_Library.Client.Class.Object.Object|REC_Library.Client.Class.Ped.Ped|REC_Library.Client.Class.Vehicle.Vehicle
---@param zoneName? string
---@return boolean
function EntityManager:register(uid, entityInstance, zoneName)
    local info = self.info

    assert(type(uid) == "string", "uid must be a string")
    assert(type(entityInstance) == "table", "entityInstance must be a table")
    if zoneName ~= nil then
        assert(type(zoneName) == "string", "zoneName must be a table")
    end

    -- Existence confirmation
    if self:doesEntityExist(uid) == true then
        utils:debugPrint("[EntityManager:register] entity was founded:", uid)
        return false
    end

    -- Registration
    info.entitiesByUniqueId[uid] = {
        entityInstance = entityInstance,
        zoneName = zoneName or nil
    }
    if zoneName ~= nil then

        -- If the zone table is empty, prepare an empty table
        if info.entitiesByZone[zoneName] == nil then
            info.entitiesByZone[zoneName] = {}
        end

        -- insert data
        info.entitiesByZone[zoneName][uid] = uid
    end

    return true
end

---Unregister
---@param uid string distinguished name
---@return boolean
function EntityManager:unregister(uid)
    local info = self.info

    assert(type(uid) == "string", "uid must be a string")

    -- Existence confirmation
    if self:doesEntityExist(uid) == false then
        utils:debugPrint("[EntityManager:unregister] entity not founded with uid:", uid)
        return false
    end

    -- Data acquisition
    local entityData = self:getEntityByUniqueId(uid)

    if entityData == nil then
        utils:debugPrint("[EntityManger:unregister] entityData was nil")
        return false
    end

    -- Cancellation of registration in zone association table
    if entityData.zoneName ~= nil then

        -- Unregistration of registered Entity
        info.entitiesByZone[entityData.zoneName][uid] = nil

        -- When the zone becomes empty, the zone frame will also disappear
        if next(info.entitiesByZone[entityData.zoneName]) == nil then
            info.entitiesByZone[entityData.zoneName] = nil
        end
    end

    -- Officially deregistered
    info.entitiesByUniqueId[uid] = nil

    return true
end

---perform destruction
---@return boolean
function EntityManager:destroy(uid)

    assert(type(uid) == "string", "uid must be a string")

    -- Existence confirmation
    if self:doesEntityExist(uid) == false then
        utils:debugPrint("[EntityManager:destroy] entity was not founded:", uid)
        return false
    end

    -- Data acquisition
    local entityData = self:getEntityByUniqueId(uid)

    if entityData == nil then
        utils:debugPrint("[EntityManger:destroy] entityData was nil")
        return false
    end

    -- discarded from world
    if entityData.entityInstance:destroy() == false then
        utils:debugPrint("[EntityManager:destroy] failed to destroy entity with uid:", uid)
    end

    return true
end

---Existence confirmation
---@param uid string distinguished name
---@return boolean
function EntityManager:doesEntityExist(uid)
    local info = self.info

    assert(type(uid) == "string", "uid must be a string")

    return info.entitiesByUniqueId[uid] ~= nil
end

---Get EntityData based on unique key
---@param uid string Unique distinguished name
---@return REC_Library.Client.Class.Manager.EntityManagerConfigBuilder.EntitiesByUniqueId|nil
function EntityManager:getEntityByUniqueId(uid)
    local info = self.info
    local entityData = info.entitiesByUniqueId[uid]

    -- Check if registered
    if entityData == nil then
        return nil
    end

    return entityData
end

---Return all registered information
---@return table<string, REC_Library.Client.Class.Manager.EntityManagerConfigBuilder.EntitiesByUniqueId>|nil
function EntityManager:getEntities()
    local info = self.info

    -- Sky check
    if next(info.entitiesByUniqueId) == nil then
        return nil
    end

    return info.entitiesByUniqueId
end


---In the zone based on the unique key
---@param zoneName string Unique distinguished name
---@return table<string, REC_Library.Client.Class.Object.Object|REC_Library.Client.Class.Ped.Ped|REC_Library.Client.Class.Vehicle.Vehicle>|nil
function EntityManager:getEntitiesByZoneName(zoneName)
    local info = self.info

    -- Check if zone exists
    if info.entitiesByZone[zoneName] == nil then
        utils:debugPrint("zoneName is not founded:", zoneName)
        return nil
    end

    ---@type table<string, REC_Library.Client.Class.Object.Object|REC_Library.Client.Class.Ped.Ped|REC_Library.Client.Class.Vehicle.Vehicle>
    local entitiesInZone = {}
    for uid, _ in pairs(info.entitiesByZone[zoneName]) do

        -- Existence confirmation
        if info.entitiesByUniqueId[uid] == nil then
            goto continue
        end

        -- Assign to return table
        entitiesInZone[uid] = info.entitiesByUniqueId[uid].entityInstance

        ::continue::
    end

    return ( next(entitiesInZone) ~= nil and entitiesInZone or nil )
end

return EntityManager
