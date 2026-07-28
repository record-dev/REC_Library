
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@class REC_Library.Client.Class.Blip.Blip
---@field info REC_Library.Client.Class.Blip.BlipConfigBuilder
local Blip = {}
Blip.__index = Blip

---instantiation
---@param config REC_Library.Client.Class.Blip.BlipConfigBuilder
---@return self
function Blip:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Blip creation
---@return number|nil
function Blip:create()
    local info = self.info

    -- create
    info.id = AddBlipForCoord(
        info.coords.x,
        info.coords.y,
        info.coords.z
    )

    -- If empty, return with error
    if info.id == nil then
        utils:debugPrint("Failed to create blip: AddBlipForCoord returned nil.")
        return nil
    end

    -- ==== Each setting ==== --

    -- Blip ID settings
    if info.sprite ~= nil and info.sprite ~= 1 then
        SetBlipSprite(info.id, info.sprite)
    end

    -- color
    if info.color ~= nil then
        SetBlipColour(info.id, info.color)
    end

    -- scale
    if info.scale ~= nil then
        SetBlipScale(info.id, info.scale)
    end

    -- Display format
    if info.display ~= nil then
        SetBlipDisplay(info.id, info.display)
    end

    -- Overlap priority
    if info.priority ~= nil then
        SetBlipPriority(info.id, info.priority)
    end

    --Category settings
    if type(info.category) == "table" and next(info.category) ~= nil and info.category.entryKey ~= nil and info.category.entryText ~= nil then
        SetBlipCategory(info.id, info.category.id)
        AddTextEntry(info.category.entryKey, info.category.entryText)
    end

    -- Transparency settings
    if info.alpha ~= 255 then -- If it is not the initial value
        SetBlipAlpha(info.id, info.alpha)
    end

    -- short range setting
    if info.isShortRange then
        SetBlipAsShortRange(info.id, info.isShortRange)
    end

    -- Flash settings
    if info.isFlashes ~= nil and info.isFlashes == true then
        if info.flashesDuration ~= nil then
            SetBlipFlashTimer(info.id, info.flashesDuration)
        else
            SetBlipFlashes(info.id, info.isFlashes)
        end
    end

    -- name setting
    if info.name ~= nil and info.name ~= "" then
        BeginTextCommandSetBlipName('STRING')
	    AddTextComponentString(tostring(info.name))
        EndTextCommandSetBlipName(info.id)
    end

    return info.id
end

---Entity handle to attach Blip
---@param enitty integer entity handle
---@return integer|nil
function Blip:createForEntity(enitty)
    local info = self.info

    -- create
    info.id = AddBlipForEntity(enitty)

    -- If empty, return with error
    if info.id == nil then
        utils:debugPrint("Failed to create blip: AddBlipForCoord returned nil.")
        return nil
    end

    -- ==== Each setting ==== --

    -- Blip ID settings
    if info.sprite ~= nil and info.sprite ~= 1 then
        SetBlipSprite(info.id, info.sprite)
    end

    -- color
    if info.color ~= nil then
        SetBlipColour(info.id, info.color)
    end

    -- scale
    if info.scale ~= nil then
        SetBlipScale(info.id, info.scale)
    end

    -- Display format
    if info.display ~= nil then
        SetBlipDisplay(info.id, info.display)
    end

    -- Overlap priority
    if info.priority ~= nil then
        SetBlipPriority(info.id, info.priority)
    end

    --Category settings
    if type(info.category) == "table" and next(info.category) ~= nil and info.category.entryKey ~= nil and info.category.entryText ~= nil then
        SetBlipCategory(info.id, info.category.id)
        AddTextEntry(info.category.entryKey, info.category.entryText)
    end

    -- Transparency settings
    if info.alpha ~= 255 then -- If it is not the initial value
        SetBlipAlpha(info.id, info.alpha)
    end

    -- short range setting
    if info.isShortRange then
        SetBlipAsShortRange(info.id, info.isShortRange)
    end

    -- Flash settings
    if info.isFlashes ~= nil and info.isFlashes == true then
        if info.flashesDuration ~= nil then
            SetBlipFlashTimer(info.id, info.flashesDuration)
        else
            SetBlipFlashes(info.id, info.isFlashes)
        end
    end

    -- name setting
    if info.name ~= nil and info.name ~= "" then
        BeginTextCommandSetBlipName('STRING')
	    AddTextComponentString(tostring(info.name))
        EndTextCommandSetBlipName(info.id)
    end

    return info.id
end

---@param bool boolean
---@return boolean
function Blip:toggleBlipRoute(bool)
    local info = self.info

    assert(type(bool) == "boolean", "bool must be a boolean")

    SetBlipRoute(info.id, bool)

    return true
end

---Switch display/hide
---@param visible boolean
function Blip:toggleVisible(visible)
    assert(type(visible) == "boolean")
    local info = self.info

    -- Check for changes
    if info.visible ~= visible then
        if visible == true then
            SetBlipAlpha(info.id, 0)
        else
            SetBlipAlpha(info.id, info.alpha)
        end
    end
end

---Returns whether deletion is complete
---@return boolean
function Blip:destroy()
    local blipId = self.info.id

    if DoesBlipExist(blipId) then
        RemoveBlip(blipId)
    end

    return true
end

return Blip
