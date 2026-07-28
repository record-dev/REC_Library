
---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

local sharedLibConfig = require "@REC_Library.shared.sh_config"

---@class REC_Library.Server.Class.Vehicle.Vehicle
---@field info REC_Library.Shared.Class.Vehicle.VehicleConfigBuilder
local Vehicle = {}
Vehicle.__index = Vehicle

---instantiation
---@param config REC_Library.Shared.Class.Vehicle.VehicleConfigBuilder
---@return self
function Vehicle:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---instantiate from handle
---@param entityHandle integer Vehicle entity handle
---@return self|nil
function Vehicle:newFromHandle(entityHandle)

    --Existence check
    if DoesEntityExist(entityHandle) == false then
        utils:debugPrint("Vehicle:newFromHandle: Entity does not exist for handle: " .. tostring(entityHandle))
        return nil
    end

    --Settings table
    ---@type REC_Library.Shared.Class.Vehicle.VehicleConfigBuilder
    local config = {
        handle = entityHandle,
        netId = NetworkGetNetworkIdFromEntity(entityHandle),
        model = "",
        modelHash = GetEntityModel(entityHandle),
        coords = GetEntityCoords(entityHandle),
        heading = GetEntityHeading(entityHandle),
        spawnTimeout = 5000,
        destroyTimeout = 5000,
        useServerSetter = false,
        isNetworked = true,
        isMissionEntity = false,
        isFreezeEntity = false,
        isResolving = false,
        routingBucket = GetEntityRoutingBucket(entityHandle) or nil,
    }

    local instance = setmetatable({}, self)
    instance.info = config

    return instance
end

---Spawn
---@param vehType? string Vehicle type
---@return boolean
function Vehicle:spawn(vehType)
    local info = self.info

    -- Play if it is not server side in the first place
    if info.isNetworked ~= true then
        utils:debugPrint("Vehicle is not networked, cannot spawn.")
        return false
    end

    -- Check if already spawned
    if info.handle ~= 0 then
        utils:debugPrint("Vehicle is already spawned.")
        return false
    end

    -- Check if it's in progress
    if info.isResolving == true then
        utils:debugPrint("Vehicle is currently resolving, cannot spawn.")
        return false
    end

    -- flag in progress
    info.isResolving = true

    -- Vehicle generation
    if info.useServerSetter == false then

        info.handle = CreateVehicle(
            info.modelHash,
            info.coords.x,
            info.coords.y,
            info.coords.z,
            info.heading,
            info.isNetworked,
            info.isMissionEntity
        )
    else

        local searchModel = sharedLibConfig.framework == "qbox" and info.model or info.modelHash

        -- If the type is easy
        if vehType ~= nil then
            goto continue
        end

        -- Get the required VehicleTypeMapping table
        if sharedLibConfig.vehicles == nil or sharedLibConfig.vehicles[searchModel] == nil then
            utils:debugPrint("Vehicle type mapping not found for searchModel: " .. (searchModel "N/A"))
            return false
        end

        -- type checking
        if sharedLibConfig.vehicles[searchModel].type == nil or type(sharedLibConfig.vehicles[searchModel].type) ~= "string" then
            utils:debugPrint("Vehicle type is not defined or is not a string for modelHash: " .. (searchModel or "N/A"))
            return false
        end

        ::continue::

        info.handle = CreateVehicleServerSetter(
            info.modelHash,
            vehType ~= nil and vehType or sharedLibConfig.vehicles[searchModel].type,
            info.coords.x,
            info.coords.y,
            info.coords.z,
            info.heading
        )
    end

    -- Wait for spawn to complete
    local currentTimeout = info.spawnTimeout
    while not DoesEntityExist(info.handle) do
        currentTimeout = currentTimeout - 100
        if currentTimeout <= 0 then
            utils:debugPrint("Failed to spawn ped with modelHash " .. (info.modelHash or "N/A"))
            return false
        end
        Wait(100)
    end

    -- Fall prevention
    FreezeEntityPosition(info.handle, true)

    -- Waiting to get NetId
    local netIdTimeout = 1500
    while info.netId == 0 do
        netIdTimeout = netIdTimeout - 100
        if netIdTimeout <= 0 then
            utils:debugPrint("Failed to get network ID for ped with modelHash " .. (info.modelHash or "N/A"))
            return false
        end
        Wait(100)
        info.netId = NetworkGetNetworkIdFromEntity(info.handle)
    end

    -- Check if netId is obtained
    if info.netId == 0 then
        utils:debugPrint("Failed to get network ID for ped with modelHash " .. (info.modelHash or "N/A"))
        return false
    end

    ---[[
    --- Various settings then
    ---]]

    if info.routingBucket ~= nil then
        SetEntityRoutingBucket(info.handle, info.routingBucket)
    end

    -- Get spawn coordinates
    info.spawnedCoords = GetEntityCoords(info.handle)

    -- Set spawn heading
    info.spawnedHeading = GetEntityHeading(info.handle)

    if info.bodyHealth ~= nil then
        SetVehicleBodyHealth(info.handle, info.bodyHealth)
    end

    if info.engineHealth ~= nil then
        SetVehicleEngineHealth(info.handle, info.engineHealth)
    end

    ---[[
    --- Various settings end
    ---]]

    ---Final fixed or not
    FreezeEntityPosition(info.handle, info.isFreezeEntity)

    -- lower in progress flag
    info.isResolving = false

    return true
end

---Discard
---@return boolean
function Vehicle:destroy()
    local info = self.info

    -- Play if it is not server side in the first place
    if info.isNetworked ~= true then
        utils:debugPrint("Vehicle is not networked, cannot spawn.")
        return false
    end

    -- Check if already spawned
    if info.handle == 0 then
        utils:debugPrint("Vehicle is not spawned.")
        return false
    end

    -- Check if it's in progress
    if info.isResolving == true then
        utils:debugPrint("Vehicle is currently resolving, cannot spawn.")
        return false
    end

    -- flag in progress
    info.isResolving = true

    -- destroy
    DeleteEntity(info.handle)

    -- Confirmation of what can be deleted
    local currentTimeout = info.destroyTimeout
    while DoesEntityExist(info.handle) == true do
        currentTimeout = currentTimeout - 100
        if currentTimeout <= 0 then
            utils:debugPrint("Failed to destroy vehicle with modelHash " .. (info.modelHash or "N/A"))
            return false
        end
        Wait(100)
    end

    -- lower in progress flag
    info.isResolving = false

    return true
end

---@return integer
function Vehicle:getHandle()
    return self.info.handle
end

---@return integer
function Vehicle:getNetId()
    return self.info.netId
end

return Vehicle
