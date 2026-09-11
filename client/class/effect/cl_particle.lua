
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type
local clientFunctions = require "@REC_Library.client.cl_functions"

---@class REC_Library.Client.Class.Effect.Particle
---@field info REC_Library.Shared.Class.Effect.ParticleConfigBuilder
---@field holdsAsset boolean
local Particle = {}
Particle.__index = Particle

-- how many instances loaded each asset through setup()
---@type table<string, integer>
local assetRefs = {}

---instantiation
---@param config REC_Library.Shared.Class.Effect.ParticleConfigBuilder
---@return self
function Particle:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    instance.holdsAsset = false
    return instance
end

---Load before drawing
---@return boolean Completed?
function Particle:setup()
    local info = self.info

    -- Check if drawing is in progress
    if info.isDrawing == true then
         utils:debugPrint("Particle is already drawing")
        return false
    end

    -- Check if it's in progress
    if info.isResolving == true then
        utils:debugPrint("Particle is already resolving")
        return false
    end

    -- flag in progress
    info.isResolving = true

    if not clientFunctions.requestNamedPtfxAsset(info.asset) then
        utils:debugPrint("Failed to load particle asset: " .. info.asset)
        info.isResolving = false
        return false
    end

    -- count the reference once per instance
    if self.holdsAsset == false then
        assetRefs[info.asset] = (assetRefs[info.asset] or 0) + 1
        self.holdsAsset = true
    end

    -- lower flag in progress
    info.isResolving = false

    return true
end

---[[
---     Fire the particle
---     A non looped particle is over the moment it fires, only a looped one keeps a
---     handle and the isDrawing flag. With an entity set the particle is attached to
---     it instead of being placed at the coords.
---]]
---@return boolean Completed?
function Particle:draw()
    local info = self.info

    -- Check if drawing is in progress
    if info.isDrawing == true then
        utils:debugPrint("Particle is already drawing")
        return false
    end

    -- Check if it's in progress
    if info.isResolving == true then
        utils:debugPrint("Particle is already resolving")
        return false
    end

    -- Check if it is set up
    if HasNamedPtfxAssetLoaded(info.asset) == false then
        utils:debugPrint("Particle asset not loaded: " .. info.asset)
        return false
    end

    -- flag in progress
    info.isResolving = true

    -- Explicitly declare assets to use
    UseParticleFxAssetNextCall(info.asset)

    local alpha = info.colour.a / 255
    local offset = info.customOffset

    if info.isLooped == false then

        if info.entity ~= nil then

            if StartParticleFxNonLoopedOnEntity(
                info.name,
                info.entity,
                offset.x, offset.y, offset.z,
                info.rotation.x, info.rotation.y, info.rotation.z,
                info.scale,
                false, -- false for now
                false, -- false for now
                false  -- false for now
            ) == false then
                utils:debugPrint(("^1failed to draw particle on entity... uid: %s^0"):format(info.uid))
                info.isResolving = false
                return false
            end

            SetParticleFxNonLoopedAlpha(alpha)

            -- lower flag in progress
            info.isResolving = false

            return true
        end

        info.handle = StartParticleFxNonLoopedAtCoord(
            info.name,
            info.coords.x, info.coords.y, info.coords.z,
            info.rotation.x, info.rotation.y, info.rotation.z,
            info.scale,
            false, -- false for now
            false, -- false for now
            false  -- false for now
        )

        -- Existence confirmation
        if info.handle == -1 then
            utils:debugPrint(("^1failed to draw particle... uid: %s^0"):format(info.uid))
            info.isResolving = false
            return false
        end

        SetParticleFxNonLoopedAlpha(alpha)

        -- lower flag in progress
        info.isResolving = false

        return true
    end

    if info.entity ~= nil then
        info.handle = StartParticleFxLoopedOnEntity(
            info.name,
            info.entity,
            offset.x, offset.y, offset.z,
            info.rotation.x, info.rotation.y, info.rotation.z,
            info.scale,
            false, -- false for now
            false, -- false for now
            false  -- false for now
        )
    else
        info.handle = StartParticleFxLoopedAtCoord(
            info.name,
            info.coords.x, info.coords.y, info.coords.z,
            info.rotation.x, info.rotation.y, info.rotation.z,
            info.scale,
            false, -- false for now
            false, -- false for now
            false, -- false for now
            false  -- unknown
        )
    end

    -- Existence confirmation
    if info.handle == -1 then
        utils:debugPrint(("^1failed to draw particle... uid: %s^0"):format(info.uid))
        info.isResolving = false
        return false
    end

    SetParticleFxLoopedColour(
        info.handle,
        info.colour.r / 255,
        info.colour.g / 255,
        info.colour.b / 255,
        true
    )

    SetParticleFxLoopedAlpha(info.handle, alpha)

    -- lower flag in progress
    info.isResolving = false

    -- Set drawing flag
    info.isDrawing = true

    return true
end

---Erase particles with loop enabled
---@return boolean Completed?
function Particle:destroy()
    local info = self.info

    -- Check if drawing is in progress
    -- if info.isDrawing ~= true then
    --     utils:debugPrint("Particle is not drawing")
    --     return false
    -- end

    -- Check if it's in progress
    if info.isResolving == true then
        utils:debugPrint("Particle is already resolving")
        return false
    end

    -- Is there any information you need?
    -- if info.handle == -1 then
    --     utils:debugPrint("Particle effect is not set or does not exist.")
    --     return false
    -- end

    -- flag in progress
    info.isResolving = true

    if info.isLooped then
        StopParticleFxLooped(info.handle, true)
    end

    -- release the asset once nobody loaded through setup() needs it
    if self.holdsAsset == true then
        self.holdsAsset = false
        assetRefs[info.asset] = (assetRefs[info.asset] or 1) - 1

        if assetRefs[info.asset] <= 0 then
            assetRefs[info.asset] = nil
            RemoveNamedPtfxAsset(info.asset)
        end
    end

    -- lower flag in progress
    info.isResolving = false

    -- lower drawing flag
    info.isDrawing = false

    return true
end

---@return integer
function Particle:getHandle()
    return self.info.handle
end

---@return boolean
function Particle:getIsDrawing()
    return self.info.isDrawing
end

---@return boolean
function Particle:getIsLooped()
    return self.info.isLooped
end

---@param coords vector3
---@param rotation vector3
---@return boolean
function Particle:setOffsets(coords, rotation)
    local info = self.info

    local newCoords = vector3(coords.x, coords.y, coords.z)
    local newRotation = vector3(rotation.x, rotation.y, rotation.z)

    if self:getIsLooped() == true then
        if DoesParticleFxLoopedExist(info.handle) == false then
            utils:debugPrint("^1particle is not exist...^0")
            return false
        end

        SetParticleFxLoopedOffsets(
            info.handle,
            newCoords.x,
            newCoords.y,
            newCoords.z,
            newRotation.x,
            newRotation.y,
            newRotation.z
        )
    end

    info.coords = newCoords
    info.rotation = newRotation

    return true
end

return Particle
