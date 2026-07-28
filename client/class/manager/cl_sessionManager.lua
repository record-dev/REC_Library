---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@class REC_Library.Client.Class.Manager.SessionManager
---@field info REC_Library.Client.Class.Manager.SessionManagerConfigBuilder
local SessionManager = {}
SessionManager.__index = SessionManager

---instantiation
---@param config REC_Library.Client.Class.Manager.SessionManagerConfigBuilder
---@return self Session
function SessionManager:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Initialization method
---@return boolean
function SessionManager:init()
    local info = self.info

    if info.onInit == nil then
        utils:debugPrint("[SessionManager:init] onInit func is not founded...")
        return false
    end

    -- Callback execution
    if info.onInit(self) == false then
        utils:debugPrint("[SessionManager:init] onInit func is get error...")
        return false
    end

    return true
end

---Client entity registration
---@param uid string Unique distinguished name
---@param entityInstance REC_Library.Client.Class.Object.Object|REC_Library.Client.Class.Ped.Ped|REC_Library.Client.Class.Vehicle.Vehicle Entity instance
---@param zoneName? string Register name of zone to which it belongs
---@return boolean
function SessionManager:registerEntity(uid, entityInstance, zoneName)
    local info = self.info

    -- If the zone identifier variable is not empty
    if zoneName ~= nil then
        assert(type(zoneName) == "string", "zoneName must be a string")
    end

    -- EntityManager existence check
    if info.entityManager == nil then
        utils:debugPrint("[SessionManager:registerEntity] EntityManager not founded")
        return false
    end

    -- Check existence of ZoneManager
    if zoneName ~= nil and info.zoneManager == nil then
        utils:debugPrint("[SessionManager:registerEntity] ZoneManager not founded")
        return false
    end

    -- Zone existence confirmation
    if zoneName ~= nil and info.zoneManager:doesZoneExist(zoneName) == false then
        utils:debugPrint("[SessionManager:registerEntity] zone not founded:", zoneName)
        return false
    end

    -- Entity registration
    if info.entityManager:register(uid, entityInstance, zoneName or nil) == false then
        utils:debugPrint("[SessionManager:registerEntity] failed to register with uid:", uid)
        return false
    end

    return true
end

---Client entity unregistration
---@param uid string Unique distinguished name
---@return boolean
function SessionManager:unregisterEntity(uid)
    local info = self.info

    -- EntityManager existence check
    if info.entityManager == nil then
        utils:debugPrint("[SessionManager:registerEntity] EntityManager not founded")
        return false
    end

    -- Unregister
    if info.entityManager:unregister(uid) == false then
        utils:debugPrint("[SessionManager:registerEntity] failed to unregister with uid:", uid)
        return false
    end

    return true
end

---Client entity unregistration
---@param zoneName string Unique distinguished name
---@param needDestroy? boolean Should it also be destroyed from the world?
---@return boolean
function SessionManager:unregisterEntitiesByZoneName(zoneName, needDestroy)
    local info = self.info
    needDestroy = needDestroy or false

    -- type check if not empty
    if needDestroy ~= nil then
        assert(type(needDestroy) == "boolean", "needDestroy must be a boolean")
    end


    -- EntityManager existence check
    if info.entityManager == nil then
        utils:debugPrint("[SessionManager:unregisterEntitiesByZoneName] EntityManager not founded")
        return false
    end

    -- Check existence of ZoneManager
    if zoneName ~= nil and info.zoneManager == nil then
        utils:debugPrint("[SessionManager:unregisterEntitiesByZoneName] ZoneManager not founded")
        return false
    end

    -- Get the list of entities belonging to the zone
    local entitiesInZone = info.entityManager:getEntitiesByZoneName(zoneName)

    -- check if empty
    if entitiesInZone == nil then
        utils:debugPrint("[SessionManager:unregisterEntitiesByZoneName] entities not founded....")
        return true -- If there is nothing registered, play as completed.
    end

    -- Discard all together
    for uid, _ in pairs(entitiesInZone) do

        -- If destruction is necessary
        if needDestroy == true then

            if info.entityManager:destroy(uid) == false then
                utils:debugPrint("[SessionManager:unregisterEntitiesByZoneName] entity was not destroyed with uid:", uid)
            end

        end

        -- destroy command
        if self:unregisterEntity(uid) == false then
            utils:debugPrint("[SessionManager:unregisterEntitiesByZoneName] entity was not unregistered with uid:", uid)
            goto continue
        end

        utils:debugPrint("[SessionManager:unregisterEntitiesByZoneName] entity was unregistered:", uid)

        ::continue::
    end

    return true
end

---Return all registered information
---@return table<string, REC_Library.Client.Class.Manager.EntityManagerConfigBuilder.EntitiesByUniqueId>|nil
function SessionManager:getEntities()
    local info = self.info

    -- EntityManager existence check
    if info.entityManager == nil then
        utils:debugPrint("[SessionManager:getEntities] EntityManager not founded")
        return nil
    end

    return info.entityManager:getEntities()
end

---Check if it exists based on the specified UID
---@param uId string
---@return REC_Library.Client.Class.Manager.EntityManagerConfigBuilder.EntitiesByUniqueId|nil
function SessionManager:getEntityByUniqueId(uId)
    local info = self.info

    -- EntityManager existence check
    if info.entityManager == nil then
        utils:debugPrint("[SessionManager:getEntityByUniqueId] EntityManager not founded")
        return nil
    end

    return info.entityManager:getEntityByUniqueId(uId)
end

---Get all Entities by zone
---@param zoneName string Zone identification name
---@return table<string, REC_Library.Client.Class.Object.Object|REC_Library.Client.Class.Ped.Ped|REC_Library.Client.Class.Vehicle.Vehicle>|nil
function SessionManager:getEntitiesByZone(zoneName)
    local info = self.info

    -- EntityManager existence check
    if info.entityManager == nil then
        utils:debugPrint("[SessionManager:getEntitiesByZone] EntityManager not founded")
        return nil
    end

    -- Check existence of ZoneManager
    if zoneName ~= nil and info.zoneManager == nil then
        utils:debugPrint("[SessionManager:getEntitiesByZone] ZoneManager not founded")
        return nil
    end

    return info.entityManager:getEntitiesByZoneName(zoneName)
end

---Zone registration
---@param zoneInstance REC_Library.Client.Class.Zone.Zone Zone instance
---@return boolean
function SessionManager:registerZone(zoneInstance)
    local info = self.info

    assert(type(zoneInstance) == "table", "zoneInstance must be a meta table")

    -- Check existence of ZoneManager
    if info.zoneManager == nil then
        utils:debugPrint("[SessionManager:registerZone] ZoneManager not founded")
        return false
    end

    -- Registration
    if info.zoneManager:register(zoneInstance) == false then
        utils:debugPrint("[SessionManager:registerZone] failed to register with zoneName:", zoneInstance.info.name)
        return false
    end

    return true
end

---Zone generation
---@param zoneName string Zone identification name
---@return boolean
function SessionManager:createZone(zoneName)
    local info = self.info

    assert(type(zoneName) == "string", "zoneName must be a string")

    -- Check existence of ZoneManager
    if info.zoneManager == nil then
        utils:debugPrint("[SessionManager:unregisterZone] ZoneManager not founded")
        return false
    end

    -- Get what is already registered
    local zoneData = info.zoneManager:getZoneByName(zoneName)

    -- Existence confirmation
    if zoneData == nil then
        utils:debugPrint("zone is not founded with zoneName:", zoneName)
        return false
    end

    -- generation instruction
    if zoneData:create() == false then
        utils:debugPrint("zone is not created with zoneName:", zoneName)
        return false
    end

    return true
end

---Unregister zone and destroy zone
---@param zoneName string Zone identification name
---@return boolean
function SessionManager:unregisterZone(zoneName)
    local info = self.info

    assert(type(zoneName) == "string", "zoneName must be a string")

    -- Check existence of ZoneManager
    if info.zoneManager == nil then
        utils:debugPrint("[SessionManager:unregisterZone] ZoneManager not founded")
        return false
    end

    -- Get data
    local zoneData = info.zoneManager:getZoneByName(zoneName)

    -- check if empty
    if zoneData == nil then
        utils:debugPrint("zoneData is nil")
        return false
    end

    -- zone destruction
    zoneData:destroy()

    -- Unregister
    if info.zoneManager:unregister(zoneName) == false then
        utils:debugPrint("[SessionManager:unregisterZone] failed to register with zoneName:", zoneName)
        return false
    end

    return true
end

---destroy all zones
---@return boolean
function SessionManager:unregisterZones()
    local info = self.info

    -- Check existence of ZoneManager
    if info.zoneManager == nil then
        utils:debugPrint("[SessionManager:unregisterZones] ZoneManager not founded")
        return false
    end

    -- Get list of existing zones
    local zones = self:getZones()

    -- if empty
    if zones == nil then
        utils:debugPrint("[SessionManager:unregisterZones] no founded zones.")
        return false
    end

    -- destroy all zones
    for key, _ in pairs(zones) do

        -- zone destruction
        if self:unregisterZone(key) == false then
            utils:debugPrint("[self:unregisterZone] failed to unregister")
            return false
        end

    end

    return true
end

---Get all zones
---@return table<string, REC_Library.Client.Class.Zone.Zone>
function SessionManager:getZones()
    local info = self.info

    -- Check existence of ZoneManager
    if info.zoneManager == nil then
        utils:debugPrint("[SessionManager:getZones] ZoneManager not founded")
        return {}
    end

    return info.zoneManager:getZones()
end

---Blip registration
---@param uid string distinguished name
---@param blip REC_Library.Client.Class.Blip.Blip
---@param group? string
---@return boolean
function SessionManager:registerBlip(uid, blip, group)
    local info = self.info

    assert(type(uid) == "string", "uid must be a string")
    assert(type(blip) == "table", "blip must be a table")

    -- Check BlipManager existence
    if info.blipManager == nil then
        utils:debugPrint("[SessionManager:registerBlip]: not founded BlipManager")
        return false
    end

    return info.blipManager:register(uid, blip, group)
end

---Blip unregistration
---@param uid string distinguished name
---@return boolean
function SessionManager:unregisterBlip(uid)
    local info = self.info

    assert(type(uid) == "string", "uid must be a string")

    -- Check BlipManager existence
    if info.blipManager == nil then
        utils:debugPrint("[SessionManager:registerBlip]: not founded BlipManager")
        return false
    end

    return info.blipManager:unregister(uid)
end

---Unregister all Blips
---@return boolean
function SessionManager:unregisterBlips()
    local info = self.info

    -- Check BlipManager existence
    if info.blipManager == nil then
        utils:debugPrint("[SessionManager:unregisterBlips]: not founded BlipManager")
        return false
    end

    for key, _ in pairs(self:getBlips()) do
        info.blipManager:unregister(key)
    end

    return true
end

---@param group string
---@return boolean
function SessionManager:unregisterBlipsByGroup(group)
    local info = self.info

    -- Check BlipManager existence
    if info.blipManager == nil then
        utils:debugPrint("[SessionManager:unregisterBlips]: not founded BlipManager")
        return false
    end

    if info.blipManager:unregisterAllByGroup(group) == false then
        utils:debugPrint("[SessionManager:unregisterBlipsByGroup]: failed to unregister blips by group:", group)
        return false
    end

    return true
end

---Get all Blips
---@return table<string, REC_Library.Client.Class.Blip.Blip>
function SessionManager:getBlips()
    local info = self.info

    -- Check BlipManager existence
    if info.blipManager == nil then
        utils:debugPrint("[SessionManager:getBlips]: not founded BlipManager")
        return {}
    end

    return info.blipManager:getBlips() or {}
end

return SessionManager
