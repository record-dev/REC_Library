
---@class REC_Library.Shared.Class.Entity.EntityProofsConfig
---@field bullet boolean
---@field fire boolean
---@field explosion boolean
---@field collision boolean
---@field melee boolean
---@field steam boolean
---@field headshot boolean
---@field water boolean

---@class REC_Library.Shared.Class.Entity.EntityProofsConfigBuilder: REC_Library.Shared.Class.Entity.EntityProofsConfig
local EntityProofsConfigBuilder = {}
EntityProofsConfigBuilder.__index = EntityProofsConfigBuilder

---@return self EntityProofsConfigBuilder
function EntityProofsConfigBuilder:new()
    local instance = setmetatable({}, self)
    instance.bullet = false
    instance.fire = false
    instance.explosion = false
    instance.collision = false
    instance.melee = false
    instance.steam = false
    instance.headshot = false
    instance.water = false
    return instance
end

---@param value boolean|nil
---@return self EntityProofsConfigBuilder method chain
function EntityProofsConfigBuilder:setBullet(value)
    if value == nil then return self end
    assert(type(value) == "boolean")
    self.bullet = value return self
end

---@param value boolean|nil
---@return self EntityProofsConfigBuilder method chain
function EntityProofsConfigBuilder:setFire(value)
    if value == nil then return self end
    assert(type(value) == "boolean")
    self.fire = value return self
end

---@param value boolean|nil
---@return self EntityProofsConfigBuilder method chain
function EntityProofsConfigBuilder:setExplosion(value)
    if value == nil then return self end
    assert(type(value) == "boolean")
    self.explosion = value return self
end

---@param value boolean|nil
---@return self EntityProofsConfigBuilder method chain
function EntityProofsConfigBuilder:setCollision(value)
    if value == nil then return self end
    assert(type(value) == "boolean")
    self.collision = value return self
end

---@param value boolean|nil
---@return self EntityProofsConfigBuilder method chain
function EntityProofsConfigBuilder:setMelee(value)
    if value == nil then return self end
    assert(type(value) == "boolean")
    self.melee = value return self
end

---@param value boolean|nil
---@return self EntityProofsConfigBuilder method chain
function EntityProofsConfigBuilder:setSteam(value)
    if value == nil then return self end
    assert(type(value) == "boolean")
    self.steam = value return self
end

---@param value boolean|nil
---@return self EntityProofsConfigBuilder method chain
function EntityProofsConfigBuilder:setHeadshot(value)
    if value == nil then return self end
    assert(type(value) == "boolean")
    self.headshot = value return self
end

---@param value boolean|nil
---@return self EntityProofsConfigBuilder method chain
function EntityProofsConfigBuilder:setWater(value)
    if value == nil then return self end
    assert(type(value) == "boolean")
    self.water = value return self
end

---@return table Return the built table
function EntityProofsConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return EntityProofsConfigBuilder
