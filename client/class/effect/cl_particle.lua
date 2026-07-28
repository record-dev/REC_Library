
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type
local clientFunctions = require "@REC_Library.client.cl_functions"

---@class REC_Library.Client.Class.Effect.Particle
---@field info REC_Library.Shared.Class.Effect.ParticleConfigBuilder
local Particle = {}
Particle.__index = Particle

---instantiation
---@param config REC_Library.Shared.Class.Effect.ParticleConfigBuilder
---@return self
function Particle:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
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

    -- lower flag in progress
    info.isResolving = false

    return true
end

---Instantaneous particle generation
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
    if not HasNamedPtfxAssetLoaded(info.asset) then
        utils:debugPrint("Particle asset not loaded: " .. info.asset)
        return false
    end

    -- flag in progress
    info.isResolving = true

    -- Explicitly declare assets to use
    UseParticleFxAssetNextCall(info.asset)

    if info.isLooped == false then

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
            utils:debugPrint(("^1failed to draw particle... uid: %s^0"):find(info.uid))
            info.isResolving = false
            return false
        end

        SetParticleFxNonLoopedAlpha(info.colour.a)

        if info.entity ~= nil then
            if not StartNetworkedParticleFxNonLoopedOnEntity(
                info.name,
                info.entity,
                info.customOffset.x, info.customOffset.y, info.customOffset.z,
                info.rotation.x, info.rotation.y, info.rotation.z,
                info.scale,
                false, -- false for now
                false, -- false for now
                false  -- false for now
            ) then
                utils:debugPrint("Failed to start networked particle effect on entity: " .. tostring(entityHandle))
                info.isResolving = false
                return false
            end
        end
    else
        info.handle = StartParticleFxLoopedAtCoord(
            info.name,
            info.coords.x, info.coords.y, info.coords.z,
            100.0, 100.0, 100.0,
            info.scale,
            false, -- false for now
            false, -- false for now
            false, -- false for now
            false  -- unknown
        )

        -- Existence confirmation
        if info.handle == -1 then
            utils:debugPrint(("^1failed to draw particle... uid: %s^0"):find(info.uid))
            info.isResolving = false
            return false
        end

        SetParticleFxLoopedColour(
            info.handle,
            info.colour.r/255,
            info.colour.g/255,
            info.colour.b/255,
            true
        )

        SetParticleFxLoopedAlpha(info.handle, info.colour.a * 1.0)

        if info.entity ~= nil then
            if StartParticleFxNonLoopedOnEntity(
                info.name,
                info.entity,
                info.customOffset.x, info.customOffset.y, info.customOffset.z,
                info.rotation.x, info.rotation.y, info.rotation.z,
                info.scale,
                false, -- false for now
                false, -- false for now
                false  -- false for now
            ) ~= true then
                utils:debugPrint("Failed to start particle effect on entity: " .. tostring(info.entityHandle))
                info.isResolving = false
                return false
            end
        end
    end

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
