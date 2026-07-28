
---@class REC_Library.Shared.Class.Vehicle.VehicleConfig
---@field uid? string
---@field handle integer
---@field netId integer
---@field routingBucket? number
---@field model string
---@field modelHash number
---@field coords vector3
---@field heading number
---@field bodyHealth? number
---@field engineHealth? number
---@field roomKeyHash integer
---@field proofs? REC_Library.Shared.Class.Entity.EntityProofsConfigBuilder
---@field plate? string
---@field fuel? number
---@field mods? REC_Library.Client.Class.Vehicle.VehicleModsConfigBuilder
---@field spawnedCoords? vector3
---@field spawnedHeading? number
---@field spawnTimeout integer
---@field destroyTimeout integer
---@field useServerSetter boolean
---@field isNetworked boolean
---@field isMissionEntity boolean
---@field isFreezeEntity boolean
---@field isResolving boolean

---@class REC_Library.Shared.Class.Vehicle.VehicleConfigBuilder: REC_Library.Shared.Class.Vehicle.VehicleConfig
local VehicleConfigBuilder = {}
VehicleConfigBuilder.__index = VehicleConfigBuilder

---@param model string
---@param coords vector3
---@param heading number
---@return self VehicleConfigBuilder
function VehicleConfigBuilder:new(model, coords, heading)
    assert(model and type(model) == "string")
    assert(coords and type(coords) == "vector3")
    assert(heading and type(heading) == "number")
    local instance = setmetatable({}, self)
    instance.handle = 0
    instance.netId = 0
    instance.model = model
    instance.modelHash = joaat(model)
    instance.coords = coords
    instance.heading = heading
    instance.spawnTimeout = 1500
    instance.destroyTimeout = 1000
    instance.useServerSetter = true
    instance.isNetworked = false
    instance.isMissionEntity = false
    instance.isFreezeEntity = false
    instance.isResolving = false
    return instance
end

---@param uid string|nil
---@return self
function VehicleConfigBuilder:setUid(uid)
    if uid == nil then return self end
    assert(type(uid) == "string")
    self.uid = uid
    return self
end

---@param routingBucket number
---@return self
function VehicleConfigBuilder:setRoutingBucket(routingBucket)
    if routingBucket == nil then return self end
    assert(type(routingBucket) == "number")
    self.routingBucket = routingBucket
    return self
end

---@param bodyHalth number|nil
---@return self
function VehicleConfigBuilder:setBodyHalth(bodyHalth)
    if bodyHalth == nil then return self end
    assert(type(bodyHalth) == "number")
    self.bodyHp = bodyHalth * 1.0
    return self
end

---@param engineHealth number|nil
---@return self
function VehicleConfigBuilder:setEngineHealth(engineHealth)
    if engineHealth == nil then return self end
    assert(type(engineHealth) == "number")
    self.engineHp = engineHealth * 1.0
    return self
end

---Room key settings
---@param roomKey integer|string|nil
---@return self
function VehicleConfigBuilder:setRoomKey(roomKey)
    if roomKey == nil then return self end
    local valueType = type(roomKey)
    assert((valueType == "number" or valueType == "string"))
    self.roomKeyHash = valueType == "string" and joaat(roomKey) or roomKey
    return self
end

---@param proofs REC_Library.Shared.Class.Entity.EntityProofsConfigBuilder|nil
---@return self
function VehicleConfigBuilder:setProofs(proofs)
    if proofs == nil then return self end
    assert(type(proofs) == "table")
    self.proofs = proofs
    return self
end

---@param plate string|nil
---@return self
function VehicleConfigBuilder:setPlate(plate)
    if plate == nil then return self end
    assert(type(plate) == "string")
    self.plate = plate
    return self
end

---@param fuel number|nil
---@return self
function VehicleConfigBuilder:setFuel(fuel)
    if fuel == nil then return self end
    assert(type(fuel) == "number")
    self.fuel = fuel
    return self
end

---@param spawnTimeout integer|nil
function VehicleConfigBuilder:setSpawnTimeout(spawnTimeout)
    if spawnTimeout == nil then return self end
    assert(type(spawnTimeout) == "number", "")
    self.spawnTimeout = spawnTimeout
end

---@param destroyTimeout integer|nil
function VehicleConfigBuilder:setDestroyTimeout(destroyTimeout)
    if destroyTimeout == nil then return self end
    assert(type(destroyTimeout) == "number", "")
    self.destroyTimeout = destroyTimeout
end

---@param doorsFlag number|nil
---@return self
function VehicleConfigBuilder:setDoorsFlag(doorsFlag)
    if doorsFlag == nil then return self end
    assert(type(doorsFlag) == "number")
    self.doorsFlag = doorsFlag
    return self
end

---@param useServerSetter boolean|nil
---@return self
function VehicleConfigBuilder:setUseServerSetter(useServerSetter)
    if useServerSetter == nil then return self end
    assert(type(useServerSetter) == "boolean")
    self.useServerSetter = useServerSetter
    return self
end


---@param isNetworked boolean|nil
---@return self
function VehicleConfigBuilder:setIsNetworked(isNetworked)
    if isNetworked == nil then return self end
    assert(type(isNetworked) == "boolean")
    self.isNetworked = isNetworked
    return self
end

---@param isMissionEntity boolean|nil
---@return self
function VehicleConfigBuilder:setisMissionEntity(isMissionEntity)
    if isMissionEntity == nil then return self end
    assert(type(isMissionEntity) == "boolean")
    self.isMissionEntity = isMissionEntity
    return self
end

---@param isFreezeEntity boolean|nil
---@return self
function VehicleConfigBuilder:setIsFreezeEntity(isFreezeEntity)
    if isFreezeEntity == nil then return self end
    assert(type(isFreezeEntity) == "boolean")
    self.isFreezeEntity = isFreezeEntity
    return self
end

---@return table table of built object settings
function VehicleConfigBuilder:build()
    local finalOptions = {}
    for k, v in pairs(self) do
        if v ~= nil then finalOptions[k] = v end
    end
    return finalOptions
end

return VehicleConfigBuilder
