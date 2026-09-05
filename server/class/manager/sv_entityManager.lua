
---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

---[[
--- Class with overall management responsibility for generated entities
---]]

---@class REC_Library.Server.Class.Manager.EntityManager
---@field info REC_Library.Server.Class.Manager.EntityManagerConfigBuilder
local EntityManager = {}
EntityManager.__index = EntityManager

---instantiation
---@param config REC_Library.Server.Class.Manager.EntityManagerConfigBuilder
---@return self
function EntityManager:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Object management without NetId
---@param uid string Unique distinguished name
---@param entityInfo REC_Library.Server.Class.Manager.EntityManagerConfigBuilder.EntitiesByUniqueId Custom parameter
---@return boolean
function EntityManager:register(uid, entityInfo)
    local info = self.info

    assert(uid ~= nil, "EntityManager:registerEntity: uid is required")

    -- Whether the unique name is already registered
    if info.entitiesByUniqueId[uid] ~= nil then
        utils:debugPrint("EntityManager:registerEntity: Entity already registered with uid: " .. uid)
        return false
    end

    -- Register unique as key
    info.entitiesByUniqueId[uid] = entityInfo

    -- If there is a zone, store it in the zone search table
    if entityInfo.zoneName ~= nil then

        -- Initialize if not present
        if info.entitiesByZone[entityInfo.zoneName] == nil then
            info.entitiesByZone[entityInfo.zoneName] = {}
        end

        -- Stored in search table
        info.entitiesByZone[entityInfo.zoneName][uid] = uid
    end

    return true
end

---Discard the Entity with the specified NetId
---@param uid string
---@param needDestroy? boolean
---@return boolean
function EntityManager:unregister(uid, needDestroy)
    local info = self.info
    needDestroy = needDestroy or false

    local entityData = self:getDataByUniqueId(uid)

    -- Existence confirmation
    if entityData == nil then
        utils:debugPrint("EntityManager:destroy: Entity not found with uid: " .. uid)
        return false
    end

    -- destroy existence
    if entityData.entityInstance:destroy() == false then
        utils:debugPrint("EntityManager:destroy: Failed to destroy entity with uid: " .. uid)
        return false
    end

    -- Cancel zone name association
    if info.entitiesByZone[entityData.zoneName] ~= nil and info.entitiesByZone[entityData.zoneName][uid] ~= nil then
        info.entitiesByZone[entityData.zoneName][uid] = nil
    end

    -- complete anthology-like destruction
    info.entitiesByUniqueId[uid] = nil
    utils:debugPrint("EntityManager:destroy: Entity unregistered from manager with uid: " .. uid)

    return true
end

---Drop the registration without touching the entity.
---For an entity that is already gone, so its uid can be used again.
---@param uid string Unique distinguished name
---@return boolean
function EntityManager:forget(uid)
    local info = self.info

    local entityData = self:getDataByUniqueId(uid)

    -- Existence confirmation
    if entityData == nil then
        utils:debugPrint("EntityManager:forget: Entity not found with uid: " .. uid)
        return false
    end

    -- Cancel zone name association
    if entityData.zoneName ~= nil and info.entitiesByZone[entityData.zoneName] ~= nil then
        info.entitiesByZone[entityData.zoneName][uid] = nil
    end

    info.entitiesByUniqueId[uid] = nil
    utils:debugPrint("EntityManager:forget: Entity forgotten with uid: " .. uid)

    return true
end

---@param needDestroy? boolean
---@return boolean
function EntityManager:unregisterAll(needDestroy)
    needDestroy = needDestroy or false

    local entities = self:getEntities()
    for key, _ in pairs(entities) do
        if self:unregister(key, needDestroy) == false then
            utils:debugPrint(("^1failed to unregsiter entity... key: %s^0"):format(key))
        end
    end

    return true
end

---Get EntityData based on unique key
---@param uid string Unique distinguished name
---@return REC_Library.Server.Class.Manager.EntityManagerConfigBuilder.EntitiesByUniqueId|nil
function EntityManager:getDataByUniqueId(uid)
    local info = self.info
    local entityData = info.entitiesByUniqueId[uid]

    -- Check if registered
    if entityData == nil then
        return nil
    end

    return entityData
end

---@return table<string, REC_Library.Server.Class.Manager.EntityManagerConfigBuilder.EntitiesByUniqueId>
function EntityManager:getEntities()
    return self.info.entitiesByUniqueId
end

---Get entity by zone name
---@param zoneName string Zone identification name
---@param customProperties? table<integer, string>
---@return table<string, REC_Library.Server.Class.Manager.EntityManager.getEntitiesByZoneName.ResultEntities>|nil
function EntityManager:getEntitiesByZoneName(zoneName, customProperties)
    local info = self.info

    -- Check if the desired zone name exists
    if info.entitiesByZone[zoneName] == nil then
        utils:debugPrint("[EntityManager:getEntitiesByZoneName] not founded zone with zonaName:", zoneName)
        return nil
    end

    -- Get tables stored by zone
    local entitiesByZone = info.entitiesByZone[zoneName]

    ---@type table<string, REC_Library.Server.Class.Manager.EntityManager.getEntitiesByZoneName.ResultEntities>
    local resultEntities = {}
    for uid, _ in pairs(entitiesByZone) do

        -- Obtain based on unique key
        local entityData = self:getDataByUniqueId(uid)

        -- If empty, move to next
        if entityData == nil then
            goto continue
        end

        local entityInstanceInfo = entityData.entityInstance.info

        -- Stored in return table
        resultEntities[uid] = {
            model = entityInstanceInfo.model,
            modelHash = entityInstanceInfo.modelHash,
            coords = entityInstanceInfo.coords,
            heading = entityInstanceInfo.heading,
            customOffset = entityInstanceInfo.customOffset or nil,
            rotation = entityInstanceInfo.rotation or nil,
            alpha = entityInstanceInfo.alpha or nil,
            lod = entityInstanceInfo.lod or nil,
            textureVariation = entityInstanceInfo.textureVariation or nil,
        }

        -- Insert additional custom properties if needed
        if customProperties ~= nil then
            for _, propertie in ipairs(customProperties) do
                if entityInstanceInfo[propertie] ~= nil then
                    resultEntities[propertie] = entityInstanceInfo[propertie]
                end
            end
        end

        ::continue::
    end

    return (next(resultEntities) ~= nil and resultEntities or nil)
end

---@class REC_Library.Server.Class.Manager.EntityManager.getEntitiesByZoneName.ResultEntities
---@field netId? integer
---@field model string
---@field modelHash integer
---@field coords vector3
---@field heading number
---@field customOffset? vector3
---@field rotation vector3
---@field alpha? number
---@field lod? number
---@field textureVariation? integer

return EntityManager
