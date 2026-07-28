
---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

---@class REC_Library.Server.Class.Object.Object
---@field info REC_Library.Shared.Class.Object.ObjectConfigBuilder
local Object = {}
Object.__index = Object

---instantiation
---@param config REC_Library.Shared.Class.Object.ObjectConfigBuilder
---@return self
function Object:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Spawn
---@return boolean
function Object:spawn()
    local info = self.info

    -- Play if it is not server side in the first place
    if info.isNetworked ~= true then
        utils:debugPrint("Object is not networked, cannot spawn.")
        return false
    end

    -- Check if already spawned
    if info.handle ~= 0 then
        utils:debugPrint("Object is already spawned.")
        return false
    end

    -- Check if it's in progress
    if info.isResolving == true then
        utils:debugPrint("Object is currently resolving, cannot spawn.")
        return false
    end

    -- flag in progress
    info.isResolving = true

    -- create
    info.handle = CreateObject(
        info.modelHash,
        info.coords.x,
        info.coords.y,
        info.coords.z,
        info.isNetworked,
        info.isMissionEntity,
        info.isDoorFlag
    )

    -- Wait for spawn to complete
    local currentTimeout = info.spawnTimeout
    while DoesEntityExist(info.handle) == false do
        currentTimeout = currentTimeout - 100
        if currentTimeout <= 0 then
            utils:debugPrint("Failed to spawn object with modelHash " .. (info.modelHash or "N/A"))
            return false
        end
        Wait(100)
    end

    ---[[
    --- Various settings
    ---]]

    -- Fixed coordinates
    FreezeEntityPosition(info.handle, info.isFreezeEntity)

    -- Get netId
    info.netId = NetworkGetNetworkIdFromEntity(info.handle)

    -- Waiting to get NetId
    local netIdTimeout = 1500
    while info.netId == 0 do
        netIdTimeout = netIdTimeout - 100
        if netIdTimeout <= 0 then
            utils:debugPrint("Failed to get network ID for obj with modelHash " .. (info.modelHash or "N/A"))
            return false
        end
        Wait(100)
        info.netId = NetworkGetNetworkIdFromEntity(info.handle)
    end

    --Reheading
    SetEntityHeading(info.handle, info.heading)

    -- Get spawn coordinates
    info.spawnedCoords = GetEntityCoords(info.handle)

    -- Set spawn heading
    info.spawnedHeading = GetEntityHeading(info.handle)

    -- lower in progress flag
    info.isResolving = false

    return true
end

---Discard
---@return boolean
function Object:destroy()
    local info = self.info

    -- Check if already spawned
    if info.handle == 0 or DoesEntityExist(info.handle) == false then
        utils:debugPrint("Object does not exist or has already been destroyed.")
        return false
    end

    -- Check if it's in progress
    if info.isResolving == true then
        utils:debugPrint("Object is currently resolving, cannot destroy.")
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
            utils:debugPrint("Failed to destroy object with modelHash " .. (info.modelHash or "N/A"))
            return false
        end
        Wait(100)
    end

    info.handle = 0

    -- lower in progress flag
    info.isResolving = false

    return true
end

---@return integer
function Object:getHandle()
    return self.info.handle
end

---@return integer
function Object:getNetId()
    return self.info.netId
end


return Object
