
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Client.Class.Object.Object
local Object = require "@REC_Library.client.class.object.cl_object"

---@type REC_Library.Shared.Class.Object.DoorConfigBuilder
local DoorConfigBuilder = require "@REC_Library.shared.class.object.sh_doorConfigBuilder"

---@class REC_Library.Client.Class.Object.Door
---@field info REC_Library.Shared.Class.Object.DoorConfigBuilder
local Door = {}
setmetatable(Door, { __index = Object })
Door.__index = Door

---@private
function Door:new()
    error("please use -> :find() method...")
end

---Find Door
---@param model integer|string
---@param coords vector3
---@return self|nil
function Door:find(model, coords)
    local modelHash = type(model) == "string" and joaat(model) or model

    ---@type integer|nil
    local doorHandle = lib.getClosestObject(coords, 5.0)
    if doorHandle == nil or doorHandle == 0 then
        utils:debugPrint("^1doorEntity is not founded...^0")
        return
    end

    local heading = GetEntityHeading(doorHandle)

    ---@type REC_Library.Shared.Class.Object.DoorConfigBuilder
    local config = {
        handle = doorHandle,
        netId = 0,
        model = model,
        modelHash = modelHash,
        coords = coords,
        heading = heading,
        spawnedCoords = coords,
        spawnedHeading = heading,
        spawnedRotation = GetEntityRotation(doorHandle),
        isLocked = false,
        isResolving = false,
    }

    local instance = Object:new(config)
    ---@cast instance REC_Library.Client.Class.Object.Door

    setmetatable(instance, self)
    instance.info = config

    return instance
end

---@return boolean
function Door:registerToSystem()
    local info = self.info

    if info.handle == 0 or DoesEntityExist == false then
        utils:debugPrint("^1door is not exist...^0")
        return false
    end

    if self:doesRegisteredInSystem() == true then
        utils:debugPrint("^1already registered...^0")
        return false
    end

    AddDoorToSystem(
        info.handle,
        info.modelHash,
        info.coords.x,
        info.coords.y,
        info.coords.z,
        false,
        false,
        false
    )

    return true
end

---@return boolean
function Door:unregisterFromSystem()
    local info = self.info

    if info.handle == 0 or DoesEntityExist == false then
        utils:debugPrint("^1door is not exist...^0")
        return false
    end

    if self:doesRegisteredInSystem() == false then
        utils:debugPrint("^1door is not registered...^0")
        return false
    end

    RemoveDoorFromSystem(info.handle)

    return true
end

---@return boolean
function Door:doesRegisteredInSystem()
    local info = self.info

    local founded, _ = DoorSystemFindExistingDoor(
        info.coords.x,
        info.coords.y,
        info.coords.z,
        info.modelHash
    )

    return founded
end

---@param state 0|1 0 == UNLOCKED | 1 == LOCKED
---@return boolean
function Door:applyState(state)
    local info = self.info

    if info.handle == 0 or DoesEntityExist == false then
        utils:debugPrint("^1door is not exist...^0")
        return false
    end

    if self:doesRegisteredInSystem() == false then
        utils:debugPrint("^1door is not registered...^0")
        return false
    end

    DoorSystemSetDoorState(info.handle, 4, false, false)
    DoorSystemSetDoorState(info.handle, state, false, false)

    return true
end

---@param isLocked boolean
function Door:setIsLocked(isLocked)
    self.info.isLocked = isLocked
end

return Door