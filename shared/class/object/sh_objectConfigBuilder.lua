
---@class REC_Library.Shared.Class.Object.ObjectConfig
---@field uid? string
---@field handle number
---@field netId integer
---@field type? string
---@field model integer|string
---@field modelHash any
---@field coords vector3
---@field customOffset? vector3
---@field heading number
---@field rotation? vector3
---@field roomKeyHash integer
---@field alpha? number
---@field lod? number
---@field textureVariation? number
---@field targetOptions? REC_Library.Client.Class.Target.OX.OXTargetConfigBuilder|REC_Library.Client.Class.Target.QB.QBTargetConfigBuilder
---@field spawnedCoords vector3
---@field spawnedHeading number
---@field spawnedRotation vector3
---@field spawnTimeout integer
---@field destroyTimeout integer
---@field isNetworked boolean
---@field isMissionEntity boolean
---@field isPlaceOnGround boolean
---@field isFreezeEntity boolean
---@field isDoorFlag boolean
---@field isResolving boolean

---@class REC_Library.Shared.Class.Object.ObjectConfigBuilder: REC_Library.Shared.Class.Object.ObjectConfig
local ObjectConfigBuilder = {}
ObjectConfigBuilder.__index = ObjectConfigBuilder

---instantiation
---@param model integer|string
---@param coords vector3
---@param heading number
function ObjectConfigBuilder:new(model, coords, heading)
    assert(model and (type(model) == "number" or type(model) == "string"))
    assert(coords and type(coords) == "vector3")
    assert(heading and type(heading) == "number")
    local instance = setmetatable({}, self)
    instance.handle = 0
    instance.netId = 0
    instance.model = model
    instance.modelHash = joaat(model)
    instance.coords = coords
    instance.heading = heading
    instance.spawnedCoords = coords
    instance.spawnedHeading = heading
    instance.spawnTimeout = 1500
    instance.destroyTimeout = 1000
    instance.isNetworked = false
    instance.isMissionEntity = false
    instance.isPlaceOnGround = false
    instance.isFreezeEntity = false
    instance.isDoorFlag = false
    instance.isResolving = false
    return instance
end

---@param uid string|nil
---@return self
function ObjectConfigBuilder:setUid(uid)
    if uid == nil then return self end
    assert(type(uid) == "string")
    self.uid = uid return self
end

---@param entityType string|nil
---@return self
function ObjectConfigBuilder:setType(entityType)
    if entityType == nil then return self end
    assert(type(string) == "string")
    self.type = entityType return self
end

---@param offset vector3|nil
---@return self
function ObjectConfigBuilder:setCustomOffset(offset)
    if offset == nil then return self end
    assert(type(offset) == "vector3")
    self.customOffset = offset return self
end

---@param rotation vector3|nil
---@return self
function ObjectConfigBuilder:setRotation(rotation)
    if rotation == nil then return self end
    assert(type(rotation) == "vector3")
    self.rotation = rotation return self
end

---@param alpha number|nil
---@return self
function ObjectConfigBuilder:setAlpha(alpha)
    if alpha == nil then return self end
    assert(type(alpha) == "number" and alpha >= 0 and alpha <= 255)
    self.alpha = alpha return self
end

---@param lod number|nil
---@return self
function ObjectConfigBuilder:setLod(lod)
    if lod == nil then return self end
    assert(type(lod) == "number")
    self.lod = lod return self
end

---@param textureVariation number|nil
---@return self
function ObjectConfigBuilder:setTextureVariation(textureVariation)
    if textureVariation == nil then return self end
    assert(type(textureVariation) == "number")
    self.textureVariation = textureVariation return self
end

---Room key settings
---@param roomKey integer|string|nil
---@return self
function ObjectConfigBuilder:setRoomKey(roomKey)
    if roomKey == nil then return self end
    local valueType = type(roomKey)
    assert((valueType == "number" or valueType == "string"))
    self.roomKeyHash = valueType == "string" and GetHashKey(roomKey) or roomKey
    return self
end

---@param targetOptions REC_Library.Client.Class.Target.OX.OXTargetConfigBuilder|REC_Library.Client.Class.Target.QB.QBTargetConfigBuilder|nil
---@return self ObjectConfigBuilder method chain
function ObjectConfigBuilder:setTargetOptions(targetOptions)
    if targetOptions == nil then return self end
    self.targetOptions = targetOptions return self
end

---@param spawnTimeout integer|nil
function ObjectConfigBuilder:setSpawnTimeout(spawnTimeout)
    if spawnTimeout == nil then return self end
    assert(type(spawnTimeout) == "number", "")
    self.spawnTimeout = spawnTimeout
end

---@param destroyTimeout integer|nil
function ObjectConfigBuilder:setDestroyTimeout(destroyTimeout)
    if destroyTimeout == nil then return self end
    assert(type(destroyTimeout) == "number", "")
    self.destroyTimeout = destroyTimeout
end

---@param isNetworked? boolean
---@return self
function ObjectConfigBuilder:setIsNetworked(isNetworked)
    if isNetworked == nil then return self end
    assert(type(isNetworked) == "boolean")
    self.isNetworked = isNetworked return self
end

---@param isMissionEntity? boolean
---@return self
function ObjectConfigBuilder:setIsMissionEntity(isMissionEntity)
    if isMissionEntity == nil then return self end
    assert(type(isMissionEntity) == "boolean")
    self.isMissionEntity = isMissionEntity return self
end

---@param isPlaceOnGround? boolean
---@return self
function ObjectConfigBuilder:setIsPlaceOnGround(isPlaceOnGround)
    if isPlaceOnGround == nil then return self end
    assert(type(isPlaceOnGround) == "boolean")
    self.isPlaceOnGround = isPlaceOnGround
    return self
end

---@param isFreezeEntity? boolean
---@return self
function ObjectConfigBuilder:setIsFreezeEntity(isFreezeEntity)
    if isFreezeEntity == nil then return self end
    assert(type(isFreezeEntity) == "boolean")
    self.isFreezeEntity = isFreezeEntity
    return self
end

---@param isDoorFlag? boolean
---@return self
function ObjectConfigBuilder:setIsDoorFlag(isDoorFlag)
    if isDoorFlag == nil then return self end
    assert(type(isDoorFlag) == "boolean")
    self.isDoorFlag = isDoorFlag return self
end

---@return table table of built object settings
function ObjectConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return ObjectConfigBuilder
