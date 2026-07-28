
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@class REC_Library.Client.Class.Effect.Sound
---@field info REC_Library.Shared.Class.Effect.SoundConfig
local Sound = {}
Sound.__index = Sound

---@param config REC_Library.Shared.Class.Effect.SoundConfig
---@return self
function Sound:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---@param coords vector3|nil
---@return self
function Sound:setCoords(coords)
    if coords == nil then return self end
    local info = self.info
    info.coords = coords
    info.soundType = "coord"
    return self
end

---@param entity integer|nil
---@return self
function Sound:setEntity(entity)
    if entity == nil then return self end
    local info = self.info
    info.entity = entity
    info.soundType = "entity"
    return self
end

---@return self
function Sound:setFrontend()
    local info = self.info
    info.soundType = "frontend"
    return self
end

---@return boolean
function Sound:setup()
    local info = self.info

    if info.soundId ~= -1 then
        utils:debugPrint("^3soundId is already setuped...^0")
        return false
    end

    info.soundId = GetSoundId()

    return info.soundId ~= -1
end


---@return boolean
function Sound:play()
    local info = self.info

    if info.soundId == -1 then
        utils:debugPrint("^3:play() soundId not setuped...^0")
        return false
    end

    -- stop once
    StopSound(info.soundId)

    if info.soundType == "frontend" then
        PlaySoundFrontend(info.soundId, info.name, info.ref, info.isNetworked)
    elseif info.soundType == "coord" then
        if info.coords == nil or type(info.coords) ~= "vector3" then
            utils:debugPrint(("^1coords is invalid value... soundId: %d^0"):format(info.soundId))
            return false
        end
        PlaySoundFromCoord(
            info.soundId,
            info.name,
            info.coords.x,
            info.coords.y,
            info.coords.z,
            info.ref,
            info.isNetworked,
            info.range,
            false
        )
    elseif info.soundType == "entity" then
        if info.entity == nil or type(info.entity) ~= "number" then
            utils:debugPrint(("^1entity is invalid value... soundId: %d^0"):format(info.soundId))
            return false
        end
        PlaySoundFromEntity(
            info.soundId,
            info.name,
            info.entity,
            info.ref,
            info.isNetworked,
            0
        )
    end

    return true
end

---@return boolean
function Sound:destroy()
    local info = self.info

    if info.soundId == -1 then
        utils:debugPrint("^3:destroy() soundId not setuped...^0")
        return false
    end

    StopSound(info.soundId)
    ReleaseSoundId(info.soundId)

    -- initialization
    info.soundId = -1

    return true
end

---@return integer
function Sound:getId()
    return self.info.soundId
end

return Sound
