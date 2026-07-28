
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Client.Functions
local clientFunctions = require "@REC_Library.client.cl_functions"

---@class REC_Library.Client.Class.Vehicle.Vehicle
---@field info REC_Library.Shared.Class.Vehicle.VehicleConfigBuilder
local Vehicle = {}
Vehicle.__index = Vehicle

---@param config REC_Library.Shared.Class.Vehicle.VehicleConfigBuilder
---@return self
function Vehicle:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---instantiate from handle
---@param entityNetId integer NetId of the entity
---@return self|nil
function Vehicle:newFromNetId(entityNetId)

    local entityHandle = NetworkGetEntityFromNetworkId(entityNetId)

    local timeout = 1200
    while DoesEntityExist(entityHandle) == false do
        utils:debugPrint("waiting exist")
        entityHandle = NetworkGetEntityFromNetworkId(entityNetId)

        if timeout <= 0 then
            utils:debugPrint("waiting timeout")
            return
        end

        timeout = timeout - 50
        Wait(100)
    end

    --Existence check
    if DoesEntityExist(entityHandle) == false then
        utils:debugPrint("Vehicle:newFromHandle: Entity does not exist for handle: " .. tostring(entityHandle))
        return nil
    end

    ---@type REC_Library.Shared.Class.Vehicle.VehicleConfigBuilder
    local config = {
        model = "",
        netId = entityNetId,
        handle = entityHandle,
        modelHash = GetEntityModel(entityHandle),
        coords = GetEntityCoords(entityHandle),
        heading = GetEntityHeading(entityHandle),
        useServerSetter = true,
        isFreezeEntity = false,
        isResolving = false
    }

    local instance = setmetatable({}, self)
    instance.info = config

    return instance
end

---Spawn vehicle
---@return boolean success or not
function Vehicle:spawn()
    local info = self.info

    -- Cancel if another location is running
    if info.isResolving then
        utils:debugPrint("Vehicle is already resolving, cannot spawn again.")
        return false
    end

    -- Existence confirmation
    if info.handle and DoesEntityExist(info.handle) then
        utils:debugPrint("Vehicle already exists with entity ID: " .. tostring(info.handle))
        return false
    end

    -- flag the process in progress
    info.isResolving = true

    -- Load model
    if not clientFunctions.requestModel(info.modelHash, 2000) then
        utils:debugPrint("Failed to load model: " .. info.model)
        info.isResolving = false
        return false
    end

    -- Vehicle generation
    info.handle = CreateVehicle(
        info.modelHash,
        info.coords.x,
        info.coords.y,
        info.coords.z,
        info.heading,
        info.isNetworked,
        info.isMissionVehicle
    )

    --Spawn confirmation
    if not info.handle or DoesEntityExist(info.handle) == false then
        info.isResolving = false -- lower processing flag
        utils:debugPrint("Failed to create vehicle entity.")
        return false
    end

    -- Fixed once to prevent falling
    FreezeEntityPosition(info.handle, true)

    -- ==== Vehicle initial settings ==== ---

    -- Obtain NetId If NetId is true but cannot be obtained, an error will occur at that point.
    if info.isNetworked then
        info.netId = NetworkGetNetworkIdFromEntity(info.handle)
        if info.netId == 0 then
            info.isResolving = false -- lower processing flag
            utils:debugPrint("Failed to get NetId for Vehicle entity.")
            return false
        end
    end

    --hp settings
    if info.hp ~= nil and info.hp ~= GetEntityHealth(info.handle) then
        SetEntityHealth(info.handle, info.hp)
    end

    --engineHP settings
    if info.engineHp ~= nil then
        SetVehicleEngineHealth(info.handle, info.engineHp)
    end

    -- Fuel settings
    if info.fuel ~= nil then
        SetVehicleFuelLevel(info.handle, info.fuel)
    end

    -- Door status settings
    if info.doorsFlag ~= nil then
        SetVehicleDoorsLocked(info.handle, info.doorsFlag)
    end

    -- Plate settings
    if info.plate ~= nil then
        SetVehicleNumberPlateText(info.handle, info.plate)
    end

    -- Mods settings
    if info.mods ~= nil then
        
    end

    -- Tolerance settings
    if info.proofs ~= nil then
        SetEntityProofs(
            info.handle,
            info.proofs.bullet or false,
            info.proofs.fire or false,
            info.proofs.explosion or false,
            info.proofs.collision or false,
            info.proofs.melee or false,
            info.proofs.steam or false,
            info.proofs.headshot or false,
            info.proofs.water or false
        )
    end

    --Give room key
    if info.roomKeyHash ~= 0 then
        ForceRoomForEntity(info.handle, GetInteriorFromEntity(info.handle), info.roomKeyHash)
    end

    -- Release of fall protection
    FreezeEntityPosition(info.handle, false)

    info.isResolving = false -- lower processing flag

    return true
end

---Delete
---@return boolean
function Vehicle:destroy()
    local info = self.info

    -- Cancel if another location is running
    if info.isResolving then
        utils:debugPrint("Vehicle is already resolving, cannot destroy.")
        return false
    end

    -- flag as running
    info.isResolving = true

    -- Existence confirmation
    if not info.handle or DoesEntityExist(info.handle) == false then
        info.isResolving = false
        utils:debugPrint("Vehicle entity does not exist.")
        return false
    end

    -- claim ownership
    -- if info.isNetworked then
    --     if not clientFunctions.requestControl(info.handle) then
    --         info.isResolving = false
    --         utils:debugPrint("Failed to request control of the vehicle entity.")
    --         return false
    --     end
    -- end

    -- Delete vehicle
    DeleteVehicle(info.handle)

    -- lower running flag
    info.isResolving = false

    return true
end

return Vehicle
