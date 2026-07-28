
---@type REC_Library.Client.Utils
local utils = require "@REC_Library.client.cl_utils"

---@type REC_Library.Shared.Validator
local validator = require "@REC_Library.shared.sh_validator"

---@class REC_Library.Shared.Class.Effect.ParticleConfig
---@field uid string
---@field handle integer
---@field entity? number
---@field coords vector3
---@field asset string
---@field name string
---@field scale number
---@field rotation vector3
---@field customOffset vector3
---@field colour REC_Library.Shared.RGBA
---@field isLooped boolean
---@field isNetworked boolean
---@field isDrawing boolean
---@field isResolving boolean

---@class REC_Library.Shared.Class.Effect.ParticleConfigBuilder: REC_Library.Shared.Class.Effect.ParticleConfig
local ParticleConfigBuilder = {}
ParticleConfigBuilder.__index = ParticleConfigBuilder

---instantiation
---@param uid string uid
---@param coords vector3 coords
---@param asset string particle group name
---@param name string Name of particle
---@param scale number float number Particle scale
---@return self
function ParticleConfigBuilder:new(uid, coords, asset, name, scale)
    assert(uid ~= nil and type(uid) == "string")
    assert(asset ~= nil and type(asset) == "string")
    assert(name ~= nil and type(name) == "string")
    assert(scale ~= nil and type(name) == "string")
    local instance = setmetatable({}, self)
    instance.uid = uid
    instance.handle = -1
    instance.coords = coords
    instance.asset = asset
    instance.name = name
    instance.scale = scale * 1.0
    instance.rotation = vector3(0.0, 0.0, 0.0)
    instance.customOffset = vector3(0.0, 0.0, 0.0)
    instance.colour = { r = 60, g = 255, b = 126, a = 255, }
    instance.isLooped = false
    instance.isNetworked = false
    instance.isDrawing = false
    instance.isResolving = false
    return instance
end

---Setting the handle of the entity that can be tracked
---@param entity number
---@return self
function ParticleConfigBuilder:setEntity(entity)
    if entity == nil then return self end
    assert(type(entity) == "number")
    self.entity = entity
    return self
end

---Whether to rotate
---@param rotation vector3|nil rotation
---@return self
function ParticleConfigBuilder:setRotation(rotation)
    if rotation == nil then return self end
    assert(type(rotation) == "vector3")
    self.rotation = rotation
    return self
end

---Color settings RGBA
---@param colour REC_Library.Shared.RGBA rgba
---@return self
function ParticleConfigBuilder:setColour(colour)
    if colour == nil then return self end
    assert(colour.r ~= nil)
    assert(colour.g ~= nil)
    assert(colour.b ~= nil)
    assert(colour.a ~= nil)
    if not validator.isTableOfStringNumber(colour) then
        utils:debugPrint("^1ParticleConfigBuilder:setColour: colour must be a table of string and number^0")
        return self
    end
    self.colour = colour
    return self
end

---Offset settings
---@param customOffset vector3|nil offset
---@return self
function ParticleConfigBuilder:setCustomOffset(customOffset)
    if customOffset == nil then return self end
    assert(type(customOffset) == "vector3")
    self.customOffset = customOffset
    return self
end

---@param isLooped boolean|nil
---@return self chain method
function ParticleConfigBuilder:setIsLooped(isLooped)
    if isLooped == nil then return self end
    assert(type(isLooped) == "boolean")
    self.isLooped = isLooped
    return self
end

---Network synchronization?
---@param isNetworked boolean|nil
---@return self chain method
function ParticleConfigBuilder:setIsNetworked(isNetworked)
    if isNetworked == nil then return self end
    assert(type(isNetworked) == "boolean")
    self.isNetworked = isNetworked
    return self
end

---Build and return with table without table method
---@return REC_Library.Shared.Class.Effect.ParticleConfig
function ParticleConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil and type(v) ~= "function" then finalOptions[k] = v end
    end
    return finalOptions
end

return ParticleConfigBuilder
