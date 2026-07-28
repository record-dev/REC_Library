
---@class REC_Library.Shared.Class.Effect.SoundConfig
---@field soundType "coord" | "entity" | "frontend"
---@field soundId integer
---@field name string
---@field ref string
---@field range number
---@field coords? vector3
---@field entity? integer
---@field isNetworked boolean

---@class REC_Library.Shared.Class.Effect.SoundConfigBuilder: REC_Library.Shared.Class.Effect.SoundConfig
local SoundConfigBuilder = {}
SoundConfigBuilder.__index = SoundConfigBuilder

---@param name string
---@param ref string
---@return self
function SoundConfigBuilder:new(name, ref)
    local instance = setmetatable({}, self)
    instance.soundType = "frontend"
    instance.soundId = -1
    instance.name = name
    instance.ref = ref
    instance.range = 0.2
    instance.isNetworked = false
    return instance
end

---@param range number
---@return self
function SoundConfigBuilder:setRange(range)
    self.range = range * 1.0
    return self
end

--- Settings can be changed using chain method
---@param isNetworked boolean
---@return self
function SoundConfigBuilder:setIsNetworked(isNetworked)
    self.isNetworked = isNetworked
    return self
end

---Build and return with table without table method
---@return REC_Library.Shared.Class.Effect.ParticleConfig
function SoundConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil and type(v) ~= "function" then finalOptions[k] = v end
    end
    return finalOptions
end

return SoundConfigBuilder
