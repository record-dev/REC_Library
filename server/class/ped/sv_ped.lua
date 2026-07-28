
---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

---@class REC_Library.Server.Class.Ped.Ped
---@field info REC_Library.Shared.Class.Ped.PedConfigBuilder
local Ped = {}
Ped.__index = Ped

---instantiation
---@param config REC_Library.Shared.Class.Ped.PedConfigBuilder
---@return self
function Ped:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Spawn
---@return boolean
function Ped:spawn()
    local info = self.info

    -- Play if it is not server side in the first place
    if info.isNetworked ~= true then
        utils:debugPrint("Ped is not networked, cannot spawn.")
        return false
    end

    -- Check if already spawned
    if info.handle ~= 0 then
        utils:debugPrint("Ped is already spawned.")
        return false
    end

    -- Check if it's in progress
    if info.isResolving == true then
        utils:debugPrint("Ped is currently resolving, cannot spawn.")
        return false
    end

    -- flag in progress
    info.isResolving = true

    -- create
    info.handle = CreatePed(
        info.type,
        info.modelHash,
        info.coords.x,
        info.coords.y,
        info.coords.z,
        info.heading,
        info.isNetworked,
        info.isSciptHosted
    )

    -- Wait for spawn to complete
    local currentTimeout = info.spawnTimeout
    while DoesEntityExist(info.handle) == false do
        currentTimeout = currentTimeout - 100
        if currentTimeout <= 0 then
            utils:debugPrint("Failed to spawn ped with modelHash " .. (info.modelHash or "N/A"))
            return false
        end
        Wait(100)
    end

    -- Fall prevention
    FreezeEntityPosition(info.handle, true)

    ---[[
    --- Various settings then
    ---]]

    -- Get netId
    info.netId = NetworkGetNetworkIdFromEntity(info.handle)

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

    -- Get spawn coordinates
    info.spawnedCoords = GetEntityCoords(info.handle)

    -- Set spawn heading
    info.spawnedHeading = GetEntityHeading(info.handle)

    --weapon settings
    if info.weapon ~= nil then
        GiveWeaponToPed(
            info.handle,
            info.weaponHash,
            info.weaponAmmo or 0,
            false,
            true -- force to hold in hand
        )
        SetCurrentPedWeapon(
            info.handle,
            info.weaponHash,
            true -- force to hold in hand
        )

        -- Accessory parts added
        if info.weaponComponents ~= nil and next(info.weaponComponents) ~= nil then
            for _, component in ipairs(info.weaponComponents) do
                GiveWeaponComponentToPed(
                    info.handle,
                    info.weaponHash,
                    component.modelHash
                )
            end
        end
    end

    if info.armour ~= nil then
        SetPedArmour(info.handle, info.armour)
    end

    ---[[
    --- Various settings end
    ---]]

    ---Final fixed or not
    FreezeEntityPosition(info.handle, info.isFreezeEntity)

    -- wait until hp syncs
    if info.hp ~= nil and info.hp ~= 0 then

        local timeout = 1200
        while GetEntityHealth(info.handle) <= 0 do
            if timeout <= 0 then
                utils:debugPrint("Failed to set health for ped with modelHash " .. (info.modelHash or "N/A"))
                return false
            end
            Citizen.Wait(100)  -- 100ms wait
            timeout = timeout - 100
        end
    end

    -- lower in progress flag
    info.isResolving = false

    return true
end

---Discard
---@return boolean
function Ped:destroy()
    local info = self.info

    -- Check if already spawned
    if info.handle == 0 or DoesEntityExist(info.handle) == false then
        utils:debugPrint("Ped does not exist or has already been destroyed.")
        return false
    end

    -- Check if it's in progress
    if info.isResolving == true then
        utils:debugPrint("Ped is currently resolving, cannot destroy.")
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
            utils:debugPrint("Failed to destroy ped with modelHash " .. (info.modelHash or "N/A"))
            return false
        end
        Wait(100)
    end

    -- lower in progress flag
    info.isResolving = false

    return true
end

---Put the Ped in the vehicle
---@param vehHandle number Vehicle handle
---@param seat number seat
---@return boolean Return whether it was successful
function Ped:putInVehicle(vehHandle, seat)
    local info = self.info

    -- Cancel if another location is running
    if info.isResolving then
        utils:debugPrint("Ped is already resolving, cannot put in vehicle.")
        return false
    end

    -- flag as running
    info.isResolving = true

    -- Existence confirmation
    if not info.handle or DoesEntityExist(info.handle) == false then
        info.isResolving = false
        utils:debugPrint("Ped entity does not exist.")
        return false
    end

    -- Vehicle presence confirmation
    if not vehHandle or DoesEntityExist(vehHandle) == false then
        info.isResolving = false
        utils:debugPrint("Vehicle entity does not exist.")
        return false
    end

    --Put the PED in the vehicle
    -- TaskWarpPedIntoVehicle(info.handle, vehHandle, seat)
    TaskEnterVehicle(
        info.handle,
        vehHandle,
        500,
        seat,
        2.0,
        16
    )

    -- lower running flag
    info.isResolving = false

    return true
end

---@return integer
function Ped:getHandle()
    return self.info.handle
end

---@return integer
function Ped:getNetId()
    return self.info.netId
end

return Ped
