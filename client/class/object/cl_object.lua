
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Client.Functions
local clientFunctions = require "@REC_Library.client.cl_functions"

---@class REC_Library.Client.Class.Object.Object
---@field info REC_Library.Shared.Class.Object.ObjectConfigBuilder
local Object = {}
Object.__index = Object

---Instanasization
---@param config REC_Library.Shared.Class.Object.ObjectConfigBuilder
---@return self
function Object:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Search and instantiate
---@param targetModel string|integer
---@param targetCoords vector3
---@param targetRadius number
---@param isMission boolean
---@return self|nil
function Object:newByFind(targetModel, targetCoords, targetRadius, isMission)
    targetRadius = targetRadius * 1.0 -- add .0 correctively

    ---@type integer
    local modelHash = (function ()
        local modelHash = nil

        if type(targetModel) == "string" then
            modelHash = joaat(targetModel)
        else
            modelHash = targetModel
        end

        return modelHash
    end)()

    local closestEntity = GetClosestObjectOfType(
        targetCoords.x,
        targetCoords.y,
        targetCoords.z,
        targetRadius,
        modelHash,
        isMission,
        false,
        false
    )

    -- wait until found
    local timeout = 2000
    while (closestEntity == nil or closestEntity == 0) and timeout > 0 do
        Wait(100)
        closestEntity = GetClosestObjectOfType(
            targetCoords.x,
            targetCoords.y,
            targetCoords.z,
            targetRadius,
            modelHash,
            isMission,
            false,
            false
        )
        timeout = timeout - 100
    end

    if closestEntity == nil or closestEntity == 0 then
        utils:debugPrint("^3entity is not founded.....^0")
        return nil
    end

    local heading = GetEntityHeading(closestEntity)

    ---@type REC_Library.Shared.Class.Object.ObjectConfigBuilder
    local config = {
        handle = closestEntity,
        netId = (function ()
            local netId = 0
            netId = NetworkGetNetworkIdFromEntity(closestEntity)
            local netIdTimeout = 1500
            while netId == 0 do
                netIdTimeout = netIdTimeout - 100
                if netIdTimeout <= 0 then
                    utils:debugPrint("Failed to get network ID for obj with modelHash " .. (tostring(targetModel) or "N/A"))
                    break
                end
                Wait(100)
                netId = NetworkGetNetworkIdFromEntity(closestEntity)
            end
            return netId
        end)(),
        model = tostring(targetModel),
        coords = targetCoords,
        heading = heading,
        spawnedCoords = targetCoords,
        spawnedHeading = heading,
        spawnedRotation = GetEntityRotation(closestEntity),
        roomKey = "",
        roomHashKey = 0,
        isResolving = false,
    }

    -- instantiation
    local instance = self:new(config)

    return instance
end

---Object spawn method
---@param isInternalReplaceCall? boolean Is it an internal call from the replace function?
---@return boolean
function Object:spawn(isInternalReplaceCall)
    local info = self.info
    isInternalReplaceCall = isInternalReplaceCall or false

    -- Cancel if running
    if not isInternalReplaceCall and info.isResolving then
        utils:debugPrint("Object:spawn: Object with UID " .. (info.uid or "N/A") .. " is already resolving.")
        return false
    end

    -- Check if spawned
    if DoesEntityExist(info.handle) == 1 then
        utils:debugPrint("Object:spawn: Object with UID " .. (info.uid or "N/A") .. " already exists.")
        return false
    end

    -- Model confirmation
    if not info.modelHash or info.modelHash == 0 then
        utils:debugPrint("Object:spawn: Invalid model hash for object with UID " .. (info.uid or "N/A"))
        return false
    end

    -- Update progress flag
    info.isResolving = true

    -- Request model with timeout
    if not clientFunctions.requestModel(info.modelHash, 2000) then
        utils:debugPrint("Object:spawn: Failed to load model for object with UID " .. (info.uid or "N/A"))
        info.isResolving = false
        return false
    end

    -- Spawn coordinate variables
    info.spawnedCoords = info.customOffset ~= nil and ( info.coords + info.customOffset ) or info.coords

    -- Object creation
    if info.customOffset ~= nil then
        info.handle = CreateObjectNoOffset(
            info.modelHash,
            info.spawnedCoords.x, info.spawnedCoords.y, info.spawnedCoords.z,
            info.isNetworked,
            info.isMissionEntity,
            info.isDoorFlag
        )
    else
        info.handle = CreateObject(
            info.modelHash,
            info.spawnedCoords.x, info.spawnedCoords.y, info.spawnedCoords.z,
            info.isNetworked,
            info.isMissionEntity,
            info.isDoorFlag
        )

    end

    --Wait until fully spawned
    local timeout = 1200
    while DoesEntityExist(info.handle) == false do
        Wait(10)

        if timeout <= 0 then
            utils:debugPrint("^1waiting timeout^0")
            return false
        end

        timeout = timeout - 10
    end

    -- === Settings === --

    -- Set room key
    if info.roomHashKey ~= 0 then
        local interiorId = GetInteriorAtCoords(info.coords.x, info.coords.y, info.coords.z)
        ForceRoomForEntity(info.handle, interiorId, info.roomKey)
        SetEntityVisible(info.handle, false, false)
        SetEntityVisible(info.handle, true, false)
    end

    -- Rotation settings
    if info.rotation ~= nil then
        SetEntityRotation(
            info.handle,
            info.rotation.x,
            info.rotation.y,
            info.rotation.z,
            0,
            true
        )
    end

    -- transparency
    if info.alpha ~= nil and info.alpha ~= 255 then
        SetEntityAlpha(info.handle, info.alpha, false)
    end

    -- LOD
    if info.lod ~= nil then
        SetEntityLodDist(info.handle, info.lod)
    end

    -- Texture variations
    if info.textureVariation ~= nil then
        SetObjectTextureVariant(info.handle, info.textureVariation)
    end

    -- installed on the ground
    if info.isPlaceOnGround == true then
        PlaceObjectOnGroundProperly(info.handle)
    end

    -- fixed
    FreezeEntityPosition(info.handle, info.isFreezeEntity)

    -- heading
    SetEntityHeading(info.handle, info.heading)

    info.spawnedRotation = GetEntityRotation(info.handle)

    -- Clear running flag
    info.isResolving = false

    return true
end

---@return boolean
function Object:respawn()
    local info = self.info

    -- Cancel if replacing
    if info.isResolving == true then
        utils:debugPrint("Object:respawn: Object with UID " .. (info.uid or "N/A") .. " is already resolving.")
        return false
    end

    -- flag
    info.isResolving = true

    --Discard if it exists
    if info.handle ~= 0 then
        self:destroy()
    end

    if self:spawn() == false then
        utils:debugPrint("Object:respawn: Failed to respawn object with UID " .. (info.uid or "N/A"))
        return false
    end

    -- Fold the flag
    info.isResolving = false

    return true
end

---Object replacement
---@param config REC_Library.Shared.Class.Object.ObjectConfigBuilder
---@return self|nil
function Object:replace(config)
    local info = self.info

    -- Cancel if required argument is invalid
    if config == nil or type(config) ~= "table" then
        utils:debugPrint("Object:replace: Invalid config provided.")
        return nil
    end

    -- Cancel if replacing
    if info.isResolving then
        utils:debugPrint("Object:replace: Object with UID " .. (info.uid or "N/A") .. " is already resolving.")
        return nil
    end

    -- Existence confirmation
    if not info.handle or DoesEntityExist(info.handle) == false then
        utils:debugPrint("Object:replace: Object with UID " .. (info.uid or "N/A") .. " does not exist.")
        return nil
    end

    -- flag replacing
    info.isResolving = true

    -- Request for ownership
    if info.isNetworked then
        if not clientFunctions.requestOwnership(info.handle, 2000) then
            utils:debugPrint("Object:replace: Failed to request ownership for object with UID " .. (info.uid or "N/A"))
            info.isResolving = false
            return nil
        end
    end

    -- Retrieve current coordinates
    config.coords = GetEntityCoords(info.handle)
    config.heading = GetEntityHeading(info.handle)

    -- Delete object
    DeleteEntity(info.handle)

    -- info replacement
    self.info = config

    -- execute spawn
    if self:spawn(true) == false then
        info.isResolving = false
        utils:debugPrint("Object:replace: Failed to spawn new object with UID " .. (info.uid or "N/A"))
        return nil
    end

    -- lower flag
    info.isResolving = false

    return self
end

---Grant interaction
---@param options? REC_Library.Client.Class.Target.OX.OXTargetConfigBuilder|REC_Library.Client.Class.Target.QB.QBTargetConfigBuilder If you want to overwrite existing targetOptions
---@return boolean
function Object:addTarget(options)
    local info = self.info

    -- Overwrite if you want to add it later
    if options ~= nil and type(options) == "table" then
        info.targetOptions = options
    end

    -- Check if option exists here
    if info.targetOptions == nil then
        utils:debugPrint("[Object:addTarget] parameter 'targetOptions' is nil")
        return false
    end

    -- Cancel if operation is in progress
    if info.isResolving then
        utils:debugPrint("Object:addTarget: Object with UID " .. (info.uid or "N/A") .. " is already resolving.")
        return false
    end

    -- Existence confirmation
    if not info.handle or DoesEntityExist(info.handle) == false then
        utils:debugPrint("Object:addTarget: Object with UID " .. (info.uid or "N/A") .. " does not exist.")
        return false
    end

    -- Operation flag enabled
    info.isResolving = true

    -- Grant
    if not clientFunctions.addTargetEntity(
        info.handle,
        info.targetOptions
    ) then
        utils:debugPrint("Object:addTarget: Failed to add target for object with UID " .. (info.uid or "N/A"))
        info.isResolving = false
        return false
    end

    -- Operation flag disabled
    info.isResolving = false

    return true
end

---Delete Object
---@return boolean success or not
function Object:destroy()
    local info = self.info

    -- Check existence of object
    if not info.handle or DoesEntityExist(info.handle) == false then
        utils:debugPrint("Object:delete: Object with UID " .. (info.uid or "N/A") .. " does not exist.")
        return false
    end

    -- Require owner permission before deleting
    if info.isNetworked and NetworkGetEntityIsNetworked(info.handle) and not NetworkHasControlOfEntity(info.handle) then
        NetworkRequestControlOfEntity(info.handle)
        local timeout = 1000
        while not NetworkHasControlOfEntity(info.handle) and timeout > 0 do
            Wait(50)
            timeout = timeout - 50
        end
        if not NetworkHasControlOfEntity(info.handle) then
            utils:debugPrint("Object:delete: Failed to gain control of object with UID " .. (info.uid or tostring(info.handle)))
            return false
        end
    end

    -- Mark as mission entity
    SetEntityAsMissionEntity(info.handle, true, true)

    -- object deletion
    DeleteEntity(info.handle)

    -- Check existence after deletion (just in case)
    if DoesEntityExist(info.handle) then
        utils:debugPrint("Object:delete: Failed to delete object with UID " .. (info.uid or "N/A") .. " (still exists after delete attempt).")
        return false
    end

    utils:debugPrint("Object:delete: Object with UID " .. (info.uid or "N/A") .. " has been deleted.")

    -- assign nil
    info.handle = 0

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

---@return vector3
function Object:getCoords()
    return self.info.coords
end

---@return number
function Object:getHeading()
    return self.info.heading
end

---@return vector3
function Object:getRotation()
    return self.info.spawnedRotation
end

---@param heading number
function Object:setHeading(heading)
    SetEntityHeading(self:getHandle(), heading)
    self.info.heading = heading
end

return Object
