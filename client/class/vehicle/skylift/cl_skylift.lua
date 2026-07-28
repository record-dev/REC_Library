
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Client.Class.Vehicle.Vehicle
local Vehicle = require "@REC_Library.client.class.vehicle.cl_vehicle"

---@class REC_Library.Client.Class.Vehicle.Skylift.Skylift: REC_Library.Client.Class.Vehicle.Vehicle
---@field info REC_Library.Shared.Class.Vehicle.Skylift.SkyliftConfigBuilder
local Skylift = {}
setmetatable(Skylift, { __index = Vehicle })
Skylift.__index = Skylift

---instantiate from handle
---@param entityHandle integer Entity Handle
---@return self|nil
function Skylift:newFromHandle(entityHandle)
    --Existence check
    if DoesEntityExist(entityHandle) == false then
        utils:debugPrint("Vehicle:newFromHandle: Entity does not exist for handle: " .. tostring(entityHandle))
        return nil
    end

    ---@type REC_Library.Shared.Class.Vehicle.Skylift.SkyliftConfigBuilder
    local config = {
        model = "recskylift",
        handle = entityHandle,
        modelHash = GetEntityModel(entityHandle),
        coords = GetEntityCoords(entityHandle),
        heading = GetEntityHeading(entityHandle),
        magnetOffset = vector3(0.0, 0.0, -0.5),
        moveDuration = 2000,
        hasAttached = false,
        useServerSetter = true,
        isFreezeEntity = false,
        isResolving = false
    }

    local instance = setmetatable({}, self)
    instance.info = config

    return instance
end

---Use magnets
---@param targetEntity integer target entity
---@return boolean
function Skylift:pickup(targetEntity)
    local info = self.info

    -- Check if skylift exists
    if info.handle == 0 or DoesEntityExist(info.handle) == false then
        utils:debugPrint("invalid skylift")
        return false
    end

    -- Check the existence of target Entity
    if targetEntity == nil or DoesEntityExist(targetEntity) == false then
        utils:debugPrint("invalid entity")
        return false
    end

    -- Flick if already lifted
    if info.hasAttached == true then
        utils:debugPrint("already pick uped")
        return false
    end

    -- Set processing in progress flag
    info.isResolving = true

    -- Disable movement
    FreezeEntityPosition(targetEntity, true)
    SetEntityCollision(targetEntity, false, false)

    local magnetOffset = vector3(0.0, 0.0, -5.0)  -- Skylift magnet offset (needs adjustment, GetWorldPositionOfEntityBone when using bone "magnet")
    local startPos = GetEntityCoords(targetEntity)

    local peakHeight = 5.0  -- peak height of parabola
    local startTime = GetGameTimer()
    while true do
        local endPos = GetOffsetFromEntityInWorldCoords(info.handle, magnetOffset.x, magnetOffset.y, magnetOffset.z)
        local elapsed = GetGameTimer() - startTime
        local t = elapsed / info.moveDuration
        if t >= 1.0 then break end

        -- horizontal lerp
        local horizontalPos = startPos + (endPos - startPos) * t
        -- Added parabola Z (simple parabola)
        local addedZ = peakHeight * (1 - (2 * t - 1)^2)  -- peak in the middle
        local finalPos = vector3(horizontalPos.x, horizontalPos.y, horizontalPos.z + addedZ)  -- create new vector3

        SetEntityCoords(
            targetEntity,
            finalPos.x, finalPos.y, finalPos.z,
            false,
            false,
            false,
            false
        )
        Citizen.Wait(0)  -- Update every frame (Wait(10) if heavy)
    end

    -- attach on exit
    AttachEntityToEntity(
        targetEntity,
        info.handle,
        GetEntityBoneIndexByName(info.handle, "magnet"),
        0.0, -3.2, -1.5,
        0.0, 0.0, 0.0,
        false,
        false,
        false,
        false,
        2,
        true
    )

    -- AttachEntityBoneToEntityBone

    FreezeEntityPosition(targetEntity, false)
    SetEntityCollision(targetEntity, true, true)

    -- flag
    info.hasAttached = true

    return true
end

---Drop the entity you are carrying
---@param entityHandle integer target entity
---@return boolean
function Skylift:drop(entityHandle)
    local info = self.info

    -- Flip if not already lifted
    if info.hasAttached == false then
        utils:debugPrint("not pick uped")
        return false
    end

    -- Set processing in progress flag
    info.isResolving = true

    -- Cancel
    DetachEntity(entityHandle, true, false)

    -- I dropped the flag, so I'll flag it down.
    info.hasAttached = false

    return true
end

return Skylift
