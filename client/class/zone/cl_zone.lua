
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Shared.Validator
local validator = require "@REC_Library.shared.sh_validator"

---@type REC_Library.Shared.Enums
local enums = require "@REC_Library.shared.sh_enums"

local zoneType = enums.ZoneType

---@class REC_Library.Client.Class.Zone.Zone
---@field info REC_Library.Shared.Class.Zone.ZoneConfigBuilder
local Zone = {}
Zone.__index = Zone

---instantiation
---@param config REC_Library.Shared.Class.Zone.ZoneConfigBuilder
---@return self
function Zone:new(config)
    assert(config ~= nil and type(config) == "table")
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Zone generation
---@return boolean success or not
function Zone:create()
    local info = self.info

    -- Check if it's in progress
    if info.isResolving == true then
        utils:debugPrint("Zone is already resolving.")
        return false
    end

    -- Check if it has already been created
    if info.isCreated == true then
        utils:debugPrint("Zone is already created.")
        return false
    end

    -- flag in progress
    info.isResolving = true

    -- Zone generation
    if info.zoneType == zoneType.PolyZone then
        info.zone = lib.zones.poly(info.options)
    elseif info.zoneType == zoneType.BoxZone then
        info.zone = lib.zones.box(info.options)
    elseif info.zoneType == zoneType.SphereZone then
        info.zone = lib.zones.sphere(info.options)
    else
        utils:debugPrint("Invalid zone type: " .. tostring(info.zoneType))
        return false
    end

    -- Final check
    if info.zone == nil or type(info.zone) ~= "table" then
        utils:debugPrint("Failed to create zone.")
        return false
    end

    -- flag as created
    info.isCreated = true

    -- lower flag in progress
    info.isResolving = false

    return true
end

---Check if the coordinates are included
---@param coords vector3
---@return boolean
function Zone:contains(coords)
    local info = self.info

    -- Check if it's in progress
    if info.isResolving == true then
        utils:debugPrint("Zone is already resolving.")
        return false
    end

    -- Check if it has been created
    if info.isCreated == false then
        utils:debugPrint("Zone is not created.")
        return false
    end

    return info.zone:contains(coords)
end

---@return boolean success or not
function Zone:destroy()
    local info = self.info

    -- Check if it's in progress
    if info.isResolving == true then
        utils:debugPrint("Zone is already resolving.")
        return false
    end

    -- Check if it has been created
    if info.isCreated == false then
        utils:debugPrint("Zone is not created.")
        return false
    end

    -- flag in progress
    info.isResolving = true

    -- Destroy zone
    info.zone:remove()

    -- empty
    info.zone = nil

    -- Fold created flag
    info.isCreated = false

    -- lower flag in progress
    info.isResolving = false

    return true
end

---@return string
function Zone:getName()
    return self.info.name
end

return Zone
